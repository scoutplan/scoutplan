# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
class MessagesController < UnitContextController
  before_action :find_message,      except: [:index, :drafts, :outbox, :scheduled, :sent, :new, :create,
                                             :recipients, :addressables, :commit]
  before_action :set_message_token, only: [:new, :edit]
  before_action :set_addressables,  only: [:new, :edit, :addressables]
  before_action :set_senders,       only: [:new, :edit]
  after_action  :create_recipients, only: [:create, :update]

  def index
    authorize Message
    redirect_to drafts_unit_messages_path(current_unit)
  end

  def drafts
    authorize Message
    scope = current_unit.messages.includes(message_recipients: [unit_membership: :user]).draft_and_queued.with_attached_attachments.order(updated_at: :desc)
    set_page_and_extract_portion_from(scope.all, per_page: [20])
  end

  def sent
    authorize Message
    scope = current_unit.messages.includes(message_recipients: [unit_membership: :user]).sent.with_attached_attachments.order(updated_at: :desc)
    set_page_and_extract_portion_from(scope.all, per_page: [20])
  end

  def outbox
    authorize Message
    scope = current_unit.messages.includes(message_recipients: [unit_membership: :user]).outbox.with_attached_attachments.order(updated_at: :desc)
    set_page_and_extract_portion_from(scope.all, per_page: [20])
  end

  def show; end

  def new
    authorize current_member.messages.new(author: current_member)
    @message = current_member.messages.new(send_at: Date.today, status: :draft)
  end

  def create
    @message = current_unit.messages.create!(message_params)
    associate_attachments
    handle_commit
    flash.now[:notice] = @notice
    redirect_to unit_messages_path(current_unit), notice: @notice
  end

  def edit
    authorize @message
    message_recipients = @message.message_recipients.includes(unit_membership: :user)
    @recipients = message_recipients.map { |m| CandidateMessageRecipient.new(m.member, :committed, "") }
  end

  def update
    @message.update(message_params)
    associate_attachments
    handle_commit
    redirect_to unit_messages_path(current_unit), notice: @notice
  end

  def destroy
    @message.destroy
    redirect_to unit_messages_path(current_unit), notice: t("messages.notices.delete_success")
  end

  def duplicate
    # authorize @message
    new_message = @message.dup
    redirect_to edit_unit_message_path(current_unit, new_message), notice: t("messages.notices.duplicate_success")
  end

  def unpin
    redirect_to unit_messages_path(current_unit), notice: t("messages.notices.unpin_success")
  end

  def addressables; end

  def commit
    return unless (key = params[:key]).present?

    type, id = key.split("_")
    @recipients = case type
                  when "membership"
                    current_unit.members.where(id: id).map { |m| CandidateMessageRecipient.new(m) }
                  when "event"
                    current_unit.events.find(id).rsvps.accepted.map { |r| CandidateMessageRecipient.new(r.member) }
                  when "dl"
                    case id
                    when "all" then current_unit.members.status_active_and_registered.includes(:user, parents:  [:user],
                                                                                                      children: [:user])
                    when "active" then current_unit.members.active.includes(:user, parents: [:user], children: [:user])
                    when "adults" then current_unit.members.active.adult.includes(:user, parents:  [:user],
                                                                                         children: [:user])
                    end
                  end

    @recipients = @recipients.select(&:adult?) if params[:member_type] == "adult"
    @recipients = @recipients.map { |m| CandidateMessageRecipient.new(m, :committed, "") }

    # find parents of youth members
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

    # concatenate, dedupe, and remove members already committed
    member_ids = params[:member_ids].map(&:to_i) || []
    @recipients += parents.flatten
    @recipients.uniq!(&:email)
    @recipients.reject! { |r| member_ids.include?(r.id) }
    @recipients.select!(&:contactable?)
  end

  private

  def associate_attachments
    return unless params[:blob_ids].present?

    params[:blob_ids].each do |blob_id|
      ActiveStorage::Attachment.create!(name: "attachments", record: @message, blob_id: blob_id)
    end
  end

  def set_addressables
    lists = current_unit.distribution_lists
    events = current_unit.events.includes(event_rsvps: [unit_membership: :user]).published.rsvp_required.recent_and_future
    members = current_unit.members.includes(:setting_objects, :event_rsvps,
                                            user: :setting_objects).order("users.last_name, users.first_name")

    @addressables = MessagingSearchResult.to_a(lists + events + members)
  end

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
    MemberNotifier.new(current_member).send_message(@message, preview: true)
  end

  def message_params
    result = params.require(:message).permit(:title, :body, :audience, :member_type,
                                             :member_status, :send_at, :author_id)
    result.merge!(sender: current_member)
    result
  end

  def find_message
    @message = Message.find(params[:id] || params[:message_id])
  end

  def create_recipients
    return unless params[:message_recipients].present?

    addressed_member_ids = params[:message_recipients][:id]
    existing_member_ids = @message.message_recipients.map(&:unit_membership_id)

    member_ids_to_delete = existing_member_ids - addressed_member_ids
    member_ids_to_add = addressed_member_ids - existing_member_ids

    @message.message_recipients.where(unit_membership_id: member_ids_to_delete).delete_all

    member_ids_to_add.each do |member_id|
      @message.message_recipients.create!(unit_membership_id: member_id)
    end
  end

  def set_message_token
    @message_token = SecureRandom.hex(10)
  end

  def set_senders
    @eligible_senders = current_unit.members.adult.status_active_and_registered
                                    .includes(:user).order("users.first_name, users.last_name")
  end
end

# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ClassLength
