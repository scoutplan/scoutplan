# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  EVENT_REGEXP = /event_(\d+)_attendees/.freeze
  before_action :find_message, except: [:index, :new, :create, :recipients]

  def index
    @draft_messages   = @unit.messages.draft
    @queued_messages  = @unit.messages.queued
    @sent_messages    = @unit.messages.sent.order("updated_at DESC")
    @pending_messages = @unit.messages.pending
    @pinned_messages  = @sent_messages.select(&:active?)
    @completed_messages = @sent_messages.reject(&:active?)
  end

  def show
  end

  def new
    authorize current_member.messages.new
    @message = current_member.messages.new(recipients: "active_members",
                                           member_type: "youth_and_adults",
                                           recipient_details: ["active"],
                                           send_at: Date.today)
  end

  def create
    @message = @unit.messages.new(message_params)
    @message.author = current_member
    @message.save!
    handle_commit
    redirect_to unit_messages_path(@unit), notice: @notice
  end

  def edit
    authorize @message
  end

  def update
    @message.update(message_params)
    handle_commit
    redirect_to unit_messages_path(@unit), notice: notice
  end

  def duplicate
    new_message = @message.dup
    new_message.title = "DUPLICATE - #{@message.title}"
    new_message.status = "draft"
    new_message.pin_until = 7.days.from_now
    new_message.send_at = Time.now
    new_message.save
    redirect_to edit_unit_message_path(@unit, new_message), notice: t("messages.notices.duplicate_success")
  end

  def unpin
    @message.update(pin_until: Time.now)
    redirect_to unit_messages_path(@unit), notice: t("messages.notices.unpin_success")
  end

  # compute the recipients for a message based on the params
  # passed in the request
  def recipients
    # pull parameters
    p = params.permit(:audience, :member_type, :member_status)
    audience = p[:audience]
    member_type = p[:member_type] == "youth_and_adults" ? %w[adult youth] : %w[adult]
    member_status = p[:member_status] == "active_and_registered" ? %w[active registered] : %w[active]

    # start building up the scope
    scope = @unit.unit_memberships.joins(:user).order(:last_name)
    scope = scope.where(member_type: member_type) # adult / youth
    
    # filter by audience
    if audience =~ EVENT_REGEXP
      event = Event.find($1)
      scope = scope.where(id: event.rsvps.pluck(:unit_membership_id))
    else
      scope = scope.where(status: member_status) # active / friends & family
    end

    # now dump it
    @recipients = scope.all
  end

  private

  def handle_commit
    case params[:commit]
    when t("messages.captions.save_draft")
      @message.update(status: :draft)
      @notice = t("messages.notices.draft_saved")
    when t("messages.captions.send_preview")
      send_preview
      @message.update(status: :draft) if @message.status.nil?
      @notice = t("messages.notices.preview_sent")
    when t("Submit for Approval")
      if MessagePolicy.new(current_member, @message).create_pending?
        @message.update(status: :pending)
        @notice = t("messages.notices.pending_success")
      end
    when t("messages.captions.send_message")
      if MessagePolicy.new(current_member, @message).create?
        @message.update(status: :queued)
        @notice = t("messages.notices.#{@message.send_now? ? 'message_sent' : 'message_queued'}")
      else
        @notice = "You aren't authorized to do that"
      end
    when t("messages.captions.delete_draft")
      @message.destroy
      @notice = t("messages.notices.delete_success")
    end

    SendMessageJob.perform_later(@message) if @message.queued?
  end

  def send_preview
    MemberNotifier.new(@current_member).send_message(@message, preview: true)
  end

  def message_params
    params.require(:message).permit(:title, :body, :recipients, :member_type, :send_at,
                                    :pin_until, :deliver_via_notification, :deliver_via_digest,
                                    recipient_details: [])
  end

  def find_message
    @message = Message.find(params[:id] || params[:message_id])
  end
end
