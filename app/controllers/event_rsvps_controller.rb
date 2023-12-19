class EventRsvpsController < EventContextController
  before_action :find_rsvp, except: [:index, :new, :create]

  def create
    if params[:unit_memberships].present?
      rsvps = create_batch
      redirect_to [@unit, @event], notice: "Your #{rsvps.count > 1 ? 'RSVPs have' : 'RSVP has'} been received."
    elsif params[:event_rsvp].present?
      create_single
    end
  end

  def edit; end

  def new
    @rsvp = @event.rsvps.new(unit_membership_id: params[:unit_membership_id])
  end

  def destroy
    authorize @rsvp
    event = @rsvp.event
    display_name = @rsvp.full_display_name
    @rsvp.destroy
    redirect_to unit_event_rsvps_path(@unit, event),
                notice: I18n.t("events.organize.confirmations.delete", name: display_name)
  end

  private

  def create_batch
    rsvps = []

    params[:unit_memberships].each do |member_id, rsvp_attributes|
      rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: member_id.to_i)
      rsvp.respondent = @current_member
      rsvp.response = rsvp_attributes[:response]
      rsvp.note = params[:note]
      rsvp.save if rsvp.changed?

      rsvps << rsvp
    end

    rsvps
  end

  def create_single
    rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: params[:member_id].to_i)
    rsvp.respondent = @current_member
    rsvp.response = params[:response]
    rsvp.save!

    [rsvp]
  end

  def find_rsvp
    @rsvp = EventRsvp.find(params[:id])
  end

  def find_event
    @event = @unit.events.find(params[:event_id])
  end

  def find_unit
    @unit = Unit.find(params[:unit_id])
  end

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end
