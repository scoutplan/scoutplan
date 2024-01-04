class FamilyRsvpsController < EventContextController
  layout "modal"

  def index
    unit_membership = params[:unit_membership_id] ? @unit.unit_memberships.find(params[:unit_membership_id]) : @current_member
    @family_rsvp = FamilyRsvp.new(unit_membership, @event)
  end

  def create
    @rsvps = []
    params[:unit_memberships].each do |unit_membership_id, rsvp_attributes|
      process_params(unit_membership_id.to_i, rsvp_attributes)
    end
  end

  private

  def process_params(unit_membership_id, rsvp_attributes)
    delete_rsvp(unit_membership_id) and return if rsvp_attributes[:response] == "nil"

    rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: unit_membership_id)
    rsvp.update(
      respondent: @current_member,
      response:   rsvp_attributes[:response],
      note:       params[:note]
    )
    @rsvps << rsvp if rsvp.changed?
  end

  def delete_rsvp(unit_membership_id)
    @event.rsvps.find_by(unit_membership_id: unit_membership_id)&.destroy
  end
end
