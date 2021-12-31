# frozen_string_literal: true

# Controller for sending messages. Interfaces between
# UI and *Notifier classes (e.g. MemberNotifier)
class MessagesController < UnitContextController
  before_action :find_member

  # POST /members/:id/messages/:message_type
  # required param :item
  # send a particular message type on demand.
  # Possible message_type values are :digest, :daily_reminder, :test_message
  def create
    authorize @member
    return unless (message_type = params[:message_type])

    method_name = "send_#{message_type}"
    @message_name = message_type.humanize.titleize
    MemberNotifier.send(method_name, @member)
  end

  private

  def find_member
    @member = UnitMembership.find(params[:member_id])
  end
end
