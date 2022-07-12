# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_message, except: [:index, :new, :create]

  def index
    @draft_messages  = current_member.messages.draft
    @sent_messages   = current_member.messages.sent
    @queued_messages = current_member.messages.queued
  end

  def new
    authorize current_member.messages.new
    @message = current_member.messages.new(recipients: "member_cohort",
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

  def edit; end

  def update
    @message.update(message_params)
    handle_commit
    redirect_to unit_messages_path(@unit), notice: notice
  end

  private

  def handle_commit
    case params[:commit]
    when "Save Draft"
      @message.update(status: :draft)
      @notice = "Draft message saved"
    when "Send Message"
      @message.update(status: :queued)
      @notice = @message.send_now? ? "Message sent" : "Message queued to send later"
    end

    SendMessageJob.perform_later(@message) if @message.queued?
  end

  def message_params
    params.require(:message).permit(:title, :body, :recipients, :member_type, :send_at, recipient_details: [])
  end

  def find_message
    @message = Message.find(params[:id])
  end
end
