# frozen_string_literal: true

require "humanize"

# controller for Events

# rubocop:disable Metrics/ClassLength
class EventsController < UnitContextController
  before_action :authenticate_user!, except: [:index, :public]
  # before_action :find_unit, only: %i[index create new edit edit_rsvps bulk_publish public]
  # before_action :find_member, only: %i[index create new edit edit_rsvps bulk_publish]
  before_action :find_event, except: %i[index create new bulk_publish public my_rsvps]
  before_action :collate_rsvps, only: [:show, :rsvps]
  layout :current_layout

  # TODO: refactor this mess
  def index
    variation = params[:variation]
    if variation.nil? && request.format.html?
      variation = cookies[:event_index_variation] || "event_table"
      case variation
      when "event_table"
        redirect_to list_unit_events_path(@unit)
        return
      when "calendar"
        redirect_to calendar_unit_events_path(@unit)
        return
      end
    end

    cookies[:event_index_variation] = variation
    cookies[:calendar_display_month] = params[:month] if params[:month]
    cookies[:calendar_display_year] = params[:year] if params[:year]

    @events = UnitEventQuery.new(current_member, current_unit).execute

    @events_by_year = @events.group_by { |e| e.starts_at.year }

    @event_drafts = @events.select(&:draft?).select{ |e| e.ends_at.future? }
    @presenter = EventPresenter.new(nil, current_member)

    if user_signed_in?
      @current_family = @current_member.family

      # kludge alert: we shouldn't generate this here, now
      @ical_magic_link = MagicLink.generate_non_expiring_link(@current_member, "icalendar") # create a MagicLink object
    end

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
      pdf: "#{@unit.name} Schedule as of #{Date.today.strftime('%-d %B %Y')}",
      layout: "pdf",
      encoding: "utf8",
      orientation: "landscape",
      header: { html: { template: "events/partials/index/calendar_header", locals: { events_by_month: calendar_events } } },
      # footer: { html: { template: "events/partials/index/calendar_footer", locals: { events_by_month: calendar_events } } },
      margin: { top: 20, bottom: 20 }
    )
  end

  def render_event_brief
    render(
      locals: { },
      pdf: "#{@unit.name} #{@event.starts_at.strftime('%B %Y')} #{@event.title} Brief",
      layout: "pdf",
      encoding: "utf8",
      orientation: "portrait",
      margin: { top: 20, bottom: 20 }
    )
  end

  def calendar_events
    if params[:season] == "next"
      events = @unit.events.includes(:event_category).where(
        "starts_at BETWEEN ? AND ?",
        @unit.next_season_starts_at,
        @unit.next_season_ends_at
      )
    else
      events = @unit.events.includes(:event_category).published.where(
        "starts_at BETWEEN ? AND ?",
        @unit.this_season_starts_at,
        @unit.this_season_ends_at
      )
    end
    # events = events.reject { |e| e.category.name == "Troop Meeting" } # TODO: not hard-wire this
    events.group_by { |e| [e.starts_at.year, e.starts_at.month] }
  end

  def show
    authorize @event
    @event_view = EventView.new(@event)
    @can_edit = policy(@event).edit?
    @can_organize = policy(@event).rsvps?
    @current_family = @current_member.family
    page_title @event.unit.name, @event.title
    respond_to do |format|
      format.html
      format.pdf do
        render_event_brief
      end
    end
  end

  def organize
    @attendees = @event.rsvps.accepted
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
    render template: "events/show"
  end

  # POST /:unit_id/events/new
  def new
    build_prototype_event
    # @event_view = EventView.new(@event)
    @presenter = EventPresenter.new(@event, current_member)
  end

  # POST /:unit_id/events
  def create
    authorize :event, :create?
    service = EventCreationService.new(@unit)
    @event = service.create(event_params)
    return unless @event.present?

    redirect_to [@unit, @event], notice: t("helpers.label.event.create_confirmation", event_name: @event.title)
  end

  # GET /:unit_id/events/:event_id/edit
  def edit
    authorize @event
    @event_view = EventView.new(@event)
  end

  # PATCH /:unit_id/events/:event_id
  def update
    authorize @event
    @event_view = EventView.new(@event)
    @event_view.assign_attributes(event_params)
    return unless @event_view.save!

    redirect_to unit_event_path(@event.unit, @event), notice: t("events.update_confirmation", title: @event.title)
  end

  # DELETE /:unit_id/events/:event_id
  def destroy
    authorize @event
    @event.destroy!
    redirect_to unit_events_path(@unit), notice: "#{@event.title} has been permanently deleted."
  end

  # organizer-facing view showing all RSVPs for an event
  def rsvps
    authorize @event
    find_next_and_previous_events
    @page_title = [@event.title, "Organize"]
    @non_invitees = @event.unit.members.status_registered - @event.rsvps.collect(&:member)
  end

  # member-facing view showing all RSVPable events and their responses
  def my_rsvps
    @events = @unit.events.rsvp_required.published.future
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

  def collate_rsvps
    @non_respondents = @event.unit.members.status_active - @event.rsvps.collect(&:member)
  end

  # the default Event will start on the first Saturday at least 4 weeks (28 days) from today
  # from 10 AM to 4 PM with RSVPs closing a week before start
  def build_prototype_event
    @event = Event.new(
      unit: @unit,
      starts_at: 28.days.from_now.next_occurring(:saturday).change({ hour: 10 }),
      ends_at: 28.days.from_now.next_occurring(:saturday).change({ hour: 16 }),
      rsvp_closes_at: 21.days.from_now.next_occurring(:saturday).change({ hour: 10 })
    )
    if (date_s = params[:date]).present?
      @event.starts_at = date_s.to_date
      @event.ends_at = date_s.to_date
    end
    set_default_times
    @event_view = EventView.new(@event)
    @member_rsvps = current_member.event_rsvps
  end

  # set sensible default start and end times based on the day of the week
  def set_default_times
    case @event.starts_at.wday
    when 0, 6 # saturday or sunday
      @event.starts_at = @event.starts_at.change({ hour: 10 })
      @event.ends_at = @event.ends_at.change({ hour: 16 })
    when 5 # friday
      @event.starts_at = @event.starts_at.change({ hour: 17 })
      @event.ends_at = @event.starts_at + 2.days
      @event.ends_at = @event.ends_at.change({ hour: 10 })
    else # mon-thurs
      @event.starts_at = @event.starts_at.change({ hour: 19 })
      @event.ends_at = @event.ends_at.change({ hour: 20, min: 30 })
    end
  end

  def find_event
    @event = @unit.events.includes(:event_rsvps).find(params[:event_id] || params[:id])
    # @current_unit = @event.unit
    # @current_member = @current_unit.membership_for(current_user)
    @presenter = EventPresenter.new(@event, @current_member)
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
      :venue_phone,
      # these ones are specifically for cancellation
      :message_audience,
      :note,
      :payment_amount
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

  def find_next_and_previous_events
    @next_event = @unit.events.published.rsvp_required.where("starts_at > ?", @event.starts_at)&.first
    @previous_event = @unit.events.published.rsvp_required.where("starts_at < ?", @event.starts_at)&.last
  end

  def current_layout
    user_signed_in? ? "application" : "public"
  end
end
# rubocop:enable Metrics/ClassLength
