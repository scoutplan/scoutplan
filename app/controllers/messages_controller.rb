# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_message, except: [:index, :new, :create]

  def index
    @draft_messages  = @unit.messages.draft
    @queued_messages = @unit.messages.queued
    @sent_messages   = @unit.messages.sent.order("updated_at DESC")
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
    when t("messages.captions.send_message")
      @message.update(status: :queued)
      @notice = t("messages.notices.#{@message.send_now? ? 'message_sent' : 'message_queued'}")
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
