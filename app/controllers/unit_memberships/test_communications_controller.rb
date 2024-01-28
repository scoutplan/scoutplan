# frozen_string_literal: true

class UnitMemberships::TestCommunicationsController < UnitContextController
  def index
    @target_member = UnitMembership.find(params[:member_id])
    authorize @target_member
  end

  def create
    @target_member = UnitMembership.find(params[:member_id])
    message_type = params[:message_type]
    return unless message_type

    send_digest if message_type == "digest"
  end

  private

  def send_digest
    # SendWeeklyDigestJob.perform_now(@target_member)
    WeeklyDigestNotifier.with(unit: @target_member.unit).deliver_later(@target_member)
  end
end
