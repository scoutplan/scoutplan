# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_message, except: [:index, :drafts, :new, :create, :recipients, :search, :commit]

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
    member_ids = params[:member_ids].map(&:to_i) || []
    return unless query.present?

    query = query.split

    if query.length == 1
      scope = @unit.members.status_active_and_registered.joins(:user).where(
        "unaccent(users.first_name) ILIKE ? OR unaccent(users.last_name) ILIKE ? " \
        "OR users.email ILIKE ? OR unaccent(users.nickname) ILIKE ?",
        "%#{query[0]}%", "%#{query[0]}%", "%#{query[0]}%", "%#{query[0]}%"
      )
    elsif query.length == 2
      scope = @unit.members.status_active_and_registered.joins(:user).where(
        "(unaccent(users.first_name) ILIKE ? OR unaccent(users.nickname) ILIKE ?) AND "\
        "unaccent(users.last_name) ILIKE ?",
        query[0], query[0], "#{query[1]}%"
      )
    end

    members = scope.all.order(:last_name, :first_name)
    ap members.count
    members = members.to_a.reject { |m| member_ids.include?(m.id) } # delete dupes
    ap members.count
    events = @unit.events.published.rsvp_required.recent_and_future
                  .includes(:event_rsvps).where("title ILIKE ?", "%#{query[0]}%")
    distribution_lists = query.length == 1 ? @unit.distribution_lists(matching: query[0]) : []
    @search_results = MessagingSearchResult.to_a(distribution_lists + members + events)
  end

  def commit
    key = params[:key]
    return unless key.present?

    key_parts = key.split("_")
    type = key_parts[0]
    id = key_parts[1]
    @recipients = @unit.members.where(id: id).map { |m| CandidateMessageRecipient.new(m) } if type == "membership"
    @recipients = @unit.events.find(id).rsvps.accepted.map { |r| CandidateMessageRecipient.new(r.member) } if type == "event"
    if type == "dl"
      @recipients = case id
                    when "all" then @unit.members.status_active_and_registered
                    when "active" then @unit.members.active
                    when "adults" then @unit.members.active.adult
                    end

      @recipients = @recipients.map { |m| CandidateMessageRecipient.new(m, :committed, "") }
    end

    parents = []
    @recipients&.each do |recipient|
      next unless recipient.member_type == "youth"

      parents << recipient.parents.to_a.map do |member|
        CandidateMessageRecipient.new(
          member, :ypt,
          "Included for two-deep communication because #{recipient.full_display_name} is a youth member addressed in this message."
        )
      end
    end

    @recipients += parents.flatten
    @recipients.uniq!(&:email)
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
