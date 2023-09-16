# frozen_string_literal: true

class UnitMemberships::TestCommunicationsController < UnitContextController
  def index
    @target_member = UnitMembership.find(params[:member_id])
    authorize @target_member
  end

  def create
    message_type = params[:message_type]
    return unless message_type

    method_name = "send_#{message_type}"
    @message_name = message_type.humanize.titleize
    @target_member = UnitMembership.find(params[:member_id])
    MemberNotifier.new(@target_member).send method_name
  end
end
