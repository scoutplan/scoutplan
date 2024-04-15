class FamilyRsvpsController < EventContextController
  layout "modal"

  before_action :find_unit_membership

  def new
    @family_rsvp = FamilyRsvp.new(@member, @event)
    authorize @family_rsvp
  end

  def create
    @rsvps = []
    params[:unit_memberships].each do |unit_membership_id, rsvp_attributes|
      process_params(unit_membership_id.to_i, rsvp_attributes)
    end
    @event_dashboard = EventDashboard.new(@event)
  end

  private

  def delete_rsvp(unit_membership_id)
    @event.rsvps.find_by(unit_membership_id: unit_membership_id)&.destroy
  end

  def process_params(unit_membership_id, rsvp_attributes)
    if rsvp_attributes[:response] == "nil"
      delete_rsvp(unit_membership_id)
      return
    end

    rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: unit_membership_id)
    rsvp.assign_attributes(
      respondent: current_member,
      response:   rsvp_attributes[:response],
      note:       params[:note]
    )
    @rsvps << rsvp if rsvp.changed? && rsvp.save
  end

  def find_unit_membership
    @member =
      if params[:unit_membership_id].present?
        current_unit.unit_memberships.find(params[:unit_membership_id])
      else
        current_member
      end
  end
end
