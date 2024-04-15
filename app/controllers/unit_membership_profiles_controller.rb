class UnitMembershipProfilesController < ApplicationController
  layout "non_unit_context"

  def index
    redirect_to member_profile_path(current_user.unit_memberships.first.id) and return unless params[:unit_membership_id].present?

    @member = UnitMembership.find(params[:unit_membership_id])
    @unit = @member.unit
  end

  def calendar
    @member = UnitMembership.find(params[:unit_membership_id])
    authorize @member
    # TODO: authorize
    @unit = @member.unit
    @alert_preferences = @member.settings(:alerts)
  end

  def update
    @member = UnitMembership.find(params[:unit_membership_id])
    authorize @member

    alert_preferences = @member.settings(:alerts)
  end

  # Policies are based on UnitMemberships, not Users, so we
  # override this method to pass the UnitMembership to Pundit
  def pundit_user
    @member
  end
end
