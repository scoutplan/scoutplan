class EventRsvpsController < EventContextController
  before_action :find_rsvp, except: [:index, :new, :create, :create_batch, :create_batch_member, :popup]

  def index
    respond_to do |format|
      format.pdf { send_event_roster }
    end
  end

  def create
    event_rsvp_params = params[:event_rsvp].permit(:unit_membership_id, :response)
    event_rsvp_params[:respondent] = current_member
    @rsvp = @event.rsvps.find_or_create_by!(event_rsvp_params)
    @event_dashboard = EventDashboard.new(@event)
  end

  def popup
    @family_rsvp = FamilyRsvp.new(current_member, @event)
  end

  def edit
    @presenter = EventPresenter.new(@event, current_member)
  end

  def update
    if params[:event_rsvp][:response] == "delete"
      @rsvp.destroy
    else
      @rsvp.update(params[:event_rsvp].permit(:unit_membership_id, :response))
    end
    @event_dashboard = EventDashboard.new(@event)
  end

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

  def find_rsvp
    @rsvp = EventRsvp.find(params[:id])
  end

  def send_event_roster
    # pdf = Pdf::EventRoster.new(@event)
    pdf = Pdf::EventOrganizerPackage.new(@event)
    send_data pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline"
  end
end
