# frozen_string_literal: true

# Controller for manipulating chat messages
class ChatMessagesController < UnitContextController
  before_action :find_event

  def index
  end

  # rubocop:disable Metrics/MethodLength
  def create
    chat = @event.initialize_chat
    @chat_message = chat.messages.new(chat_message_params)
    if chat_message_params[:author_id].present? && ChatMessagePolicy.new(current_member, @chat_message).impersonate?
      @chat_message.author_id = chat_message_params[:author_id]
    else
      @chat_message.author = current_member
    end
    @chat_message.save!

    Turbo::StreamsChannel.broadcast_prepend_later_to(
      "chat_#{chat.id}",
      :chat_messages,
      partial: "chat_messages/chat_message",
      target: "chat_messages",
      locals: { chat_message: @chat_message, current_member: @current_member }
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            :new_chat_message,
            partial: "events/partials/show/new_chat_message",
            locals: { current_member: current_member, event: @event }
          )
        ]
      end
    end

    ChatNotifier.perform_later(@chat_message)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def chat_message_params
    params.require(:chat_message).permit(:message, :author_id)
  end

  def find_event
    @event = @unit.events.find(params[:event_id])
  end
end
