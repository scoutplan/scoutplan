class FamilyRsvpsController < EventContextController
  layout "modal"

  before_action :find_unit_membership

  def new
    @family_rsvp = FamilyRsvp.new(@member, @event)
    authorize @family_rsvp
  end

  def create
    @rsvps = []

    params[:unit_memberships]&.each do |unit_membership_id, rsvp_attributes|
      process_params(unit_membership_id.to_i, rsvp_attributes)
    end

    process_event_shifts

    @event_dashboard = EventDashboard.new(@event)
  end

  private

  def delete_rsvp(unit_membership_id)
    @event.rsvps.find_by(unit_membership_id: unit_membership_id)&.destroy
  end

  def process_event_shifts
    member_params = params.dig(:event, :members)
    return unless member_params.present?

    member_params.each do |member_id, responses|
      rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: member_id)
      accepted_shift_ids = responses[:shifts].select { |_shift_id, response_h| response_h[:response] == "accepted" }.keys
      response = accepted_shift_ids.empty? ? "declined" : "accepted"
      rsvp.assign_attributes(
        respondent:      current_member,
        response:        response,
        event_shift_ids: accepted_shift_ids
      )
      rsvp.save!
    end
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


# "event"=>{"members"=>{"1"=>{"shifts"=>{"4"=>{"response"=>"accepted"}, "5"=>{"response"=>"declined"}, "6"=>{"response"=>"declined"}}}, "7"=>{"shifts"=>{"4"=>{"response"=>"declined"}, "5"=>{"response"=>"declined"}, "6"=>{"response"=>"declined"}}}, "6"=>{"shifts"=>{"4"=>{"response"=>"declined"}, "5"=>{"response"=>"declined"}, "6"=>{"response"=>"declined"}}}}}