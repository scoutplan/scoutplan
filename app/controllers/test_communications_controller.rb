# frozen_string_literal: true

# Controller for sending test messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class TestCommunicationsController < UnitContextController
  # POST /members/:id/messages/:message_type
  # send a particular message type on demand.
  # Possible message_type values are :digest, :daily_reminder, :test_message
  def create
    authorize current_member
    return unless (message_type = params[:message_type])

    method_name = "send_#{message_type}"
    @message_name = message_type.humanize.titleize
    target_member = UnitMembership.find(params[:member_id])
    MemberNotifier.new(target_member).send method_name
  end
end
