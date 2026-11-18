# frozen_string_literal: true

class UnitMemberships::TestCommunicationsController < UnitContextController
  def index
    @target_member = UnitMembership.find(params[:member_id])
    authorize @target_member
  end

  def create
    @target_member = UnitMembership.find(params[:member_id])
    authorize @target_member
    return head(:unprocessable_entity) unless params[:message_type] == "digest"

    send_digest
    redirect_back fallback_location: unit_member_test_communications_path(current_unit, @target_member),
                  notice: t("settings.notices.digest_test_sent", email: @target_member.email)
  end

  private

  def send_digest
    # SendWeeklyDigestJob.perform_now(@target_member.unit.id)
    unit = @target_member.unit
    WeeklyDigestNotifier.with(unit: unit, digest_note_html: unit.digest_note_html).deliver(@target_member)
  end
end
