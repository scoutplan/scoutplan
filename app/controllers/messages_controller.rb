# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_message, except: [:index, :drafts, :new, :create, :recipients, :search]

  def index
    redirect_to pending_unit_messages_path(@unit) and return if @unit.messages.pending.any?

    redirect_to new_unit_message_path(@unit)

    # @draft_messages   = @unit.messages.draft.with_attached_attachments
    # @queued_messages  = @unit.messages.queued.with_attached_attachments
    # @sent_messages    = @unit.messages.sent.order("updated_at DESC").with_attached_attachments
    # @pending_messages = @unit.messages.pending.with_attached_attachments
  end

  def drafts
    @messages = @unit.messages.draft.with_attached_attachments
  end

  def show; end

  def new
    authorize current_member.messages.new
    @drafts_count = @unit.messages.draft.count
    @message = current_member.messages.new(send_at: Date.today, status: :draft)
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
    new_message.send_at = Time.now
    new_message.save
    redirect_to edit_unit_message_path(@unit, new_message), notice: t("messages.notices.duplicate_success")
  end

  def unpin
    redirect_to unit_messages_path(@unit), notice: t("messages.notices.unpin_success")
  end

  # compute the recipients for a message based on the params
  # passed in the request
  def recipients
    p = params.permit(:audience, :member_type, :member_status)
    audience      = p[:audience]
    member_type   = p[:member_type]
    member_status = p[:member_status]

    message = Message.new(
      author:        @unit.unit_memberships.first,
      audience:      audience,
      member_type:   member_type,
      member_status: member_status
    )
    service = MessageService.new(message)
    @recipients = service.resolve_members
  end

  def search
    query = params[:query]

    scope = @unit.members.active.joins(:user).where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
    @members = scope.all.order(:last_name, :first_name)
    @search_results = EmailSearchResult.to_a(@members)
  end

  private

  def handle_commit
    case params[:commit]

    # save draft
    when t("messages.captions.save_draft")
      @message.update(status: :draft)
      @notice = t("messages.notices.draft_saved")

    # send preview
    when t("messages.captions.send_preview")
      send_preview
      @message.update(status: :draft) if @message.status.nil?
      @notice = t("messages.notices.preview_sent")

    # submit for approval
    when t("Submit for Approval")
      if MessagePolicy.new(current_member, @message).create_pending?
        @message.update(status: :pending)
        @notice = t("messages.notices.pending_success")
      end

    # schedule
    when t("messages.captions.schedule_and_save")
      if MessagePolicy.new(current_member, @message).create?
        @message.update(status: :queued)
        @notice = t("messages.notices.message_sent")
      else
        @notice = "You aren't authorized to do that"
      end

    # send now
    when t("messages.captions.send_message")
      if MessagePolicy.new(current_member, @message).create?
        @message.update(status: :outbox)
        @notice = t("messages.notices.message_sent")
      else
        @notice = "You aren't authorized to do that"
      end

    # delete
    when t("messages.captions.delete_draft")
      @message.destroy
      @notice = t("messages.notices.delete_success")
    end
  end

  def send_preview
    MemberNotifier.new(@current_member).send_message(@message, preview: true)
  end

  def message_params
    params.require(:message).permit(:title, :body, :audience, :member_type, :member_status, :send_at)
  end

  def find_message
    @message = Message.find(params[:id] || params[:message_id])
  end
end
