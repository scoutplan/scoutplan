# frozen_string_literal: true

require "humanize"

# controller for Events

# rubocop:disable Metrics/ClassLength
class EventsController < UnitContextController
  before_action :authenticate_user!, except: :public
  # before_action :find_unit, only: %i[index create new edit edit_rsvps bulk_publish public]
  # before_action :find_member, only: %i[index create new edit edit_rsvps bulk_publish]
  before_action :find_event, except: %i[index create new bulk_publish public]

  # TODO: refactor this mess
  def index
    if params[:variation].nil?
      redirect_to cookies[:events_index_path] and return \
        if cookies[:events_index_path].present?

      redirect_to list_unit_events_path(@unit)
    end

    store_path
    @events = UnitEventQuery.new(current_member, current_unit).execute
    @event_drafts = @events.select(&:draft?)
    @presenter = EventPresenter.new
    @current_family = @current_member.family
    @current_year = @current_month = nil

    # kludge alert: we shouldn't generate this here, now
    @ical_magic_link = MagicLink.generate_link(@current_member, "icalendar", :never) # create a MagicLink object
    page_title @unit.name, t("events.index.title")
    respond_to do |format|
      format.html
      format.pdf do
        render_printable_calendar
      end
    end
  end

  def public
    @events = @unit.events.published.future.limit(params[:limit] || 4)

    # TODO: limit this to the unit's designated site(s)
    response.headers["X-Frame-Options"] = "ALLOW"
    render "public_index", layout: "public"
  end

  def render_printable_calendar
    render(
      locals: { events_by_month: calendar_events },
      pdf: "#{@unit.name} Event Calendar",
      layout: "pdf",
      encoding: "utf8",
      orientation: "landscape",
      header: { html: { template: "events/partials/index/calendar_header", locals: { events_by_month: calendar_events } } },
      footer: { html: { template: "events/partials/index/calendar_footer", locals: { events_by_month: calendar_events } } },
      margin: { top: 20, bottom: 20 }
    )
  end

  def calendar_events
    events = @unit.events.includes(:event_category).published
    events = events.reject { |e| e.category.name == "Troop Meeting" } # TODO: not hard-wire this
    events.group_by { |e| [e.starts_at.year, e.starts_at.month] }
  end

  def show
    authorize @event
    @event_view = EventView.new(@event)
    @can_edit = policy(@event).edit?
    @can_organize = policy(@event).organize?
    @current_family = @current_member.family
    page_title @event.unit.name, @event.title
  end

  # GET /units/:unit_id/events/:id/rsvp
  # this is a variation on the 'show' action that swaps
  # out the RSVP panel on the modal with a form where users
  # can add/user their RSVPs.
  # TODO: is there a better, more RESTful way of doing this?
  def edit_rsvps
    authorize @event
    @unit = Unit.find(params[:unit_id])
    @event = Event.find(params[:event_id])
    @event_view = EventView.new(@event)
    @current_member = @unit.membership_for(current_user)
  end

  def new
    build_prototype_event
    # @event_view = EventView.new(@event)
    @presenter = EventPresenter.new(event: @event, current_user: current_user)
  end

  def create
    authorize :event, :create?
    service = EventCreationService.new(@unit)
    @event = service.create(event_params)
    return unless @event.present?

    redirect_to [@unit, @event], notice: t("helpers.label.event.create_confirmation", event_name: @event.title)
  end

  def edit
    authorize @event
    @event_view = EventView.new(@event)
  end

  def update
    authorize @event

    @event_view = EventView.new(@event)
    @event_view.assign_attributes(event_params)
    return unless @event_view.save!

    redirect_to unit_event_path(@event.unit, @event), notice: t("events.update_confirmation", title: @event.title)
  end

  def organize
    authorize @event

    @unit = @event.unit
    @next_event = @unit.events.published.future.rsvp_required.where("starts_at > ?", @event.starts_at)&.first
    @previous_event = @unit.events.published.future.rsvp_required.where("starts_at < ?", @event.starts_at).order("starts_at DESC")&.first

    @page_title = [@event.title, "Organize"]
    @non_respondents = @event.unit.members.status_active - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members.status_registered - @event.rsvps.collect(&:member)
  end

  def publish
    authorize @event
    return if @event.published? # don't publish it twice

    @event.update!(status: :published)

    # TODO: EventNotifier.after_publish(@event)
    flash[:notice] = t("events.publish_message", title: @event.title)
    redirect_to @event
  end

  # POST /units/:id/events/bulk_publish
  def bulk_publish
    event_ids = params[:event_ids]
    events    = Event.find(event_ids)

    events.each do |event|
      event.update!(status: :published)
    end

    # TODO: EventNotifier.after_bulk_publish(@unit, events)
    flash[:notice] = t("events.index.bulk_publish.success_message")

    redirect_to unit_events_path(@unit)
  end

  # POST /units/:unit_id/events/:id/rsvp
  def create_or_update_rsvps
    note = params[:note]
    params[:event][:members].each do |member_id, values|
      response = values[:event_rsvp][:response]
      includes_activity = values[:event_rsvp][:includes_activity] == "1"
      rsvp = @event.rsvps.create_with(
        response: response,
        includes_activity: includes_activity,
        note: note,
        respondent: @current_member
      ).find_or_create_by!(unit_membership_id: member_id)

      rsvp.update!(response: response, respondent: @current_member, note: note)
      # EventNotifier.send_rsvp_confirmation(rsvp)
    end

    @unit = @event.unit
    @current_member = @unit.membership_for(current_user)
    @current_family = @current_member.family

    if (member_id = params[:member_id].presence)
      redirect_to unit_member_path(@unit, member_id), notice: t("events.edit_rsvps.notices.update")
    else
      redirect_to [@unit, @event], notice: t("events.edit_rsvps.notices.update")
    end
  end

  # GET cancel
  # display cancel dialog where user confirms cancellation and where
  # notification options are chosen
  def cancel
    redirect_to [@unit, @event], alert: "Event is already cancelled." and return if @event.cancelled?
  end

  # POST cancel
  # actually cancel the event and send out notifications
  # rubocop:disable Style/GuardClause
  def perform_cancellation
    service = EventCancellationService.new(@event, event_params)
    if service.cancel
      redirect_to unit_events_path(@unit), notice: t("events.show.cancel.confirmation", event_title: @event.title)
    end
  end
  # rubocop:enable Style/GuardClause

  # this override is needed to pass the membership instead of the user
  # as the object to be evaluated in Pundit policies
  def pundit_user
    @current_member
  end

  private

  # the default Event will start on the first Saturday at least 4 weeks (28 days) from today
  # from 10 AM to 4 PM with RSVPs closing a week before start
  def build_prototype_event
    @event = Event.new(
      unit: @unit,
      starts_at: 28.days.from_now.next_occurring(:saturday).change({ hour: 10 }),
      ends_at: 28.days.from_now.next_occurring(:saturday).change({ hour: 16 }),
      rsvp_closes_at: 21.days.from_now.next_occurring(:saturday).change({ hour: 10 })
    )
    @event_view = EventView.new(@event)
    @member_rsvps = current_member.event_rsvps
  end

  def find_event
    @event = @unit.events.includes(:event_rsvps).find(params[:id] || params[:event_id])
    # @current_unit = @event.unit
    # @current_member = @current_unit.membership_for(current_user)
    @presenter = EventPresenter.new(event: @event, current_user: current_user)
  end

  # permitted parameters
  # rubocop:disable Metrics/MethodLength
  def event_params
    params.require(:event).permit(
      :title,
      :event_category_id,
      :location,
      :address,
      :description,
      :short_description,
      :requires_rsvp,
      :includes_activity,
      :activity_name,
      :starts_at_date,
      :starts_at_time,
      :ends_at_date,
      :ends_at_time,
      :repeats,
      :repeats_until,
      :departs_from,
      :status,
      # these ones are specifically for cancellation
      :message_audience,
      :note
    )
  end
  # rubocop:enable Metrics/MethodLength

  def event_set_datetimes
    event_set_start
    event_set_end
  end

  def event_set_start
    return unless params[:starts_at_d] && params[:starts_at_t]

    @event.starts_at = ScoutplanUtilities.compose_datetime(
      params[:starts_at_d],
      params[:starts_at_t]
    ).utc
  end

  def event_set_end
    return unless params[:ends_at_d] && params[:ends_at_t]

    @event.ends_at = ScoutplanUtilities.compose_datetime(
      params[:ends_at_d],
      params[:ends_at_t]
    ).utc
  end

  def store_path
    cookies[:events_index_path] = request.original_fullpath
  end
end
# rubocop:enable Metrics/ClassLength
