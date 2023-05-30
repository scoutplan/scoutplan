class UnitMembershipProfilesController < ApplicationController
  layout "non_unit_context"

  def calendar
    @member = UnitMembership.find(params[:unit_membership_id])
    @unit = @member.unit
  end
end
