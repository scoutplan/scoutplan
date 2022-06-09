# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  def index
    @draft_messages = current_member.messages.draft
    @sent_messages = current_member.messages.sent
  end

  def new
    authorize current_member.messages.new
    @message = current_member.messages.new
  end
end
