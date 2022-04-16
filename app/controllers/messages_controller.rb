# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  def index
    @messages = current_member.messages
  end

  def new
    authorize current_member.messages.new
    @message = current_member.messages.new
  end
end
