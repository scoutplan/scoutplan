class FamilyRsvpsController < EventContextController
  layout "modal"

  def index
    unit_membership = params[:unit_membership_id] ? @unit.unit_memberships.find(params[:unit_membership_id]) : @current_member
    @family_rsvp = FamilyRsvp.new(unit_membership, @event)
  end
end
