# frozen_string_literal: true

class MessagesController < UnitContextController
  before_action :find_message, except: [:index, :drafts, :scheduled, :sent, :new, :create, :recipients, :search, :commit]
  after_action :create_recipients, only: [:create, :update]

  def index
    redirect_to drafts_unit_messages_path(@unit)
  end

  def drafts
    @messages = @unit.messages.draft.with_attached_attachments.order(updated_at: :desc)
  end

  def sent
    @messages = @unit.messages.sent.with_attached_attachments.order(updated_at: :desc)
  end

  def scheduled
    @messages = @unit.messages.queued.with_attached_attachments.order(updated_at: :desc)
  end

  def show; end

  def new
    authorize current_member.messages.new
    @drafts_count = @unit.messages.draft.count
    @message = current_member.messages.new(send_at: Date.today, status: :draft)
  end

  def create
    @message = @unit.messages.create!(message_params)
    handle_commit
    redirect_to unit_messages_path(@unit), notice: @notice
  end

  def edit
    authorize @message
    @recipients = @message.message_recipients.map { |m| CandidateMessageRecipient.new(m.member, :committed, "") }
  end

  def update
    @message.update(message_params)
    handle_commit
    redirect_to unit_messages_path(@unit), notice: notice
  end

  def destroy
    @message.destroy
    redirect_to unit_messages_path(@unit), notice: t("messages.notices.delete_success")
  end

  def duplicate
    new_message = @message.dup
    new_message.update(
      title:   "DUPLICATE - #{@message.title}",
      status:  "draft",
      send_at: Time.now
    )
    redirect_to edit_unit_message_path(@unit, new_message), notice: t("messages.notices.duplicate_success")
  end

  def unpin
    redirect_to unit_messages_path(@unit), notice: t("messages.notices.unpin_success")
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
    members = members.to_a.reject { |m| member_ids.include?(m.id) }
    events = @unit.events.published.rsvp_required.recent_and_future
                  .includes(:event_rsvps).where("title ILIKE ?", "%#{query[0]}%")
    distribution_lists = query.length == 1 ? @unit.distribution_lists(matching: query[0]) : []
    # TODO: tags
    @search_results = MessagingSearchResult.to_a(distribution_lists + members + events)
  end

  def commit
    key = params[:key]
    return unless key.present?

    member_ids = params[:member_ids].map(&:to_i) || []

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
    @recipients.reject! { |r| member_ids.include?(r.id) } # delete dupes
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
        @message.update!(status: :outbox)
        @notice = t("messages.notices.message_sent")
      else
        @notice = "You aren't authorized to do that"
      end
    end
  end

  def send_preview
    MemberNotifier.new(@current_member).send_message(@message, preview: true)
  end

  def message_params
    ap params
    result = params.require(:message).permit(:title, :body, :audience, :member_type, :member_status, :send_at)
    result.merge!(author: @current_member) unless result[:author].present?
    result
  end

  def find_message
    @message = Message.find(params[:id] || params[:message_id])
  end

  def create_recipients
    @message.message_recipients.destroy_all
    return unless params[:message_recipients].present?

    member_ids = params[:message_recipients][:id]

    member_ids.each do |id|
      member = @unit.members.find(id.to_i)
      ap member
      @message.message_recipients.create!(unit_membership: member)
    end
  end
end
