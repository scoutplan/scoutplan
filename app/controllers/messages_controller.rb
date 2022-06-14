# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_message, except: [ :index, :new, :create ]

  def index
    @draft_messages = current_member.messages.draft
    @sent_messages = current_member.messages.sent
  end

  def new
    authorize current_member.messages.new
    @message = current_member.messages.new
  end

  def create
    @message = @unit.messages.new(message_params)
    @message.author = current_member
    @message.status = "draft" if params[:commit] == "Save Draft" # < this is bogus
    if @message.save!
      redirect_to unit_messages_path(@unit), notice: "Message created"
    end
  end

  def edit
  end

  private

  def message_params
    params.require(:message).permit(:title, :body)
  end

  def find_message
    @message = Message.find(params[:id])
  end
end
