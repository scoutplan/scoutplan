# frozen_string_literal: true

# Controller for sending test messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class TestCommunicationsController < UnitContextController
  # POST /members/:id/messages
  # send a particular message type on demand.
  # Possible message_type values are :digest, :daily_reminder, :test_message
  def create
    authorize current_member
    message_type = params[:message_type]
    return unless message_type

    method_name = "send_#{message_type}"
    ap method_name
    @message_name = message_type.humanize.titleize
    target_member = UnitMembership.find(params[:member_id])
    MemberNotifier.new(target_member).send method_name
  end
end
