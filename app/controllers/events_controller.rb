# frozen_string_literal: true

require "humanize"

# controller for Events
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
class EventsController < UnitContextController
  skip_before_action :authenticate_user!, only: [:public]
  before_action :find_event, except: %i[
    list calendar paged_list spreadsheet create new bulk_publish public my_rsvps signups
  ]
  before_action :collate_rsvps, only: [:show, :rsvps]
  before_action :set_calendar_dates, only: [:calendar, :list, :paged_list]
  before_action :remember_unit_events_path, only: [:list, :calendar]
  layout :current_layout

  def calendar
    unless params[:year] && params[:month]
      redirect_to calendar_unit_events_path(@unit, year: Date.today.year, month: Date.today.month) and return
    end

    @events = scope_for_calendar.all
  end

  def history
    @versions = @event.versions
  end

  def list
    respond_to do |format|
      format.html { find_list_events }
      format.pdf { send_fridge_calendar }
      format.turbo_stream { prepare_turbo_stream }
    end
  end

  def paged_list
    respond_to do |format|
      format.html { @events = scope_for_list.all }
      format.pdf { send_fridge_calendar }
      format.turbo_stream { prepare_turbo_stream }
    end
  end

  def public
    @events = @unit.events.published.future.limit(params[:limit] || 4)

    # TODO: limit this to the unit's designated site(s)
    response.headers["X-Frame-Options"] = "ALLOW"
    render "public_index", layout: "public"
  end

  def show
    authorize @event
    @can_edit = policy(@event).edit?
    @can_organize = policy(@event).rsvps?
    @current_family = @current_member.family
    if @event.requires_payment? && Flipper.enabled?(:payments, @unit)
      @payments = @event.payments.paid.where(unit_membership_id: @current_family.map(&:id))
      @family_rsvps = @event.rsvps.where(unit_membership_id: @current_family.map(&:id))
      @subtotal = (@family_rsvps.accepted.youth.count * @event.cost_youth) + (@family_rsvps.accepted.adult.count * @event.cost_adult)
      @transaction_fee = @unit.payments_enabled? ? StripePaymentService.new(@unit).member_transaction_fee(@subtotal) : 0
      @total_cost = @subtotal + @transaction_fee
      @total_paid = (@payments&.sum(:amount) || 0) / 100
      @amount_due = @total_cost - @total_paid
    end
    page_title @unit.name, @event.title
    respond_to do |format|
      format.html
      format.pdf { send_event_brief }
      format.ics { send_ical }
    end
  end

  def organize
    @attendees = @event.rsvps.accepted
    @payments_service = PaymentsService.new(@event)
  end

  # GET /:unit_id/events/:event_id/edit
  def edit
    authorize @event
    %w[departure arrival activity].each do |location_type|
      @event.event_locations.find_or_initialize_by(location_type: location_type)
    end
  end

  # GET /units/:unit_id/events/:id/rsvp
  # this is a variation on the 'show' action that swaps
  # out the RSVP panel on the modal with a form where users
  # can add/user their RSVPs.
  # TODO: is there a better, more RESTful way of doing this?
  def edit_rsvps
    authorize @event
  end

  # POST /:unit_id/events/new
  def new
    authorize Event

    if params[:parent_event_id]
      @parent_event = @unit.events.find(params[:parent_event_id])
      redirect_to unit_events_path(@unit), status: :user_not_authorized unless EventPolicy.new(current_member, @parent_event).edit?
    end

    if (source_event_id = params[:source_event_id])
      @event = EventDuplicationService.new(@unit, source_event_id).build
    else
      build_prototype_event
    end
    @presenter = EventPresenter.new(@event, current_member)
  end

  # POST /:unit_id/events
  def create
    authorize :event, :create?
    service = EventCreationService.new(@unit)
    @event = service.create(event_params)
    EventOrganizerService.new(@event, @current_member).update(params[:event_organizers])
    EventService.new(@event, params).process_event_shifts
    return unless @event.present?

    if params[:event][:attachments].present?
      params[:event][:attachments].each do |attachment|
        @event.attachments.attach(attachment)
      end
    end

    redirect_to [@unit, @event], notice: t("helpers.label.event.create_confirmation", event_name: @event.title)
  end

  # PATCH /:unit_id/events/:event_id
  def update
    destroy and return if params[:event_action] == "delete"

    authorize @event
    service = EventUpdateService.new(@event, @current_member, event_params)
    service.perform

    EventService.new(@event, params).process_event_shifts
    EventService.new(@event, params).process_library_attachments
    EventOrganizerService.new(@event, @current_member).update(params[:event_organizers])

    if cookies[:event_index_variation] == "calendar"
      redirect_to calendar_unit_events_path(@unit), notice: t("events.update_confirmation", title: @event.title)
    else
      redirect_to unit_event_path(@event.unit, @event), notice: t("events.update_confirmation", title: @event.title)
    end
  end

  # DELETE /:unit_id/events/:event_id
  def destroy
    authorize @event
    if @event.series_parent.present?
      @unit.events.where(series_parent_id: @event.series_parent_id).destroy_all
    else
      @event.destroy!
    end
    redirect_to unit_events_path(@unit), notice: "#{@event.title} has been permanently removed from the schedule."
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

  def signups
    @events = @unit.events.rsvp_required.published.future
    respond_to do |format|
      format.pdf do
        render_printable_signups
      end
    end
  end

  def render_printable_signups
    events = @events.select(&:rsvp_open?)

    render(locals: { events: events },
           pdf: "#{@unit.name} Signups as of #{Date.today.strftime('%-d %B %Y')}",
           layout: "pdf",
           encoding: "utf8",
           orientation: "landscape",
           margin: { top: 20, bottom: 20 },
           header: { html: { template: "events/partials/index/signup_header" } } )
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
      member = @current_unit.members.find(member_id)
      values[:event_rsvp] ||= {}
      shifts = values[:shifts]
      accepted_shifts = shifts.present? ? shifts.select { |_, v| v[:response] == "accepted" }.keys : []

      response = if shifts.present?
                   accepted_shifts.count.positive? ? "accepted" : "declined"
                 else
                   values[:event_rsvp][:response]
                 end

      if response == "nil"
        @event.rsvps.find_by(unit_membership_id: member_id)&.destroy
        next
      end

      # youth responses are always pending
      # TODO: move this logic elsewhere
      if response == "accepted" && @current_member.youth?
        response = "accepted_pending"
      elsif response == "declined" && @current_member.youth?
        response = "declined_pending"
      end

      includes_activity = values[:event_rsvp][:includes_activity] == "1"
      rsvp = @event.rsvps.create_with(
        response:          response,
        note:              note,
        respondent:        @current_member,
        event_shift_ids:   accepted_shifts,
        includes_activity: includes_activity
      ).find_or_create_by!(unit_membership_id: member_id)

      rsvp.update!(response: response,
                   respondent: @current_member,
                   note: note,
                   event_shift_ids: accepted_shifts)

      EventNotifier.send_rsvp_confirmation(rsvp)
    end

    @unit = @event.unit
    @current_member = @unit.membership_for(current_user)
    @current_family = @current_member.family

    if (member_id = params[:member_id].presence)
      redirect_to unit_member_path(@unit, member_id), notice: t("events.edit_rsvps.notices.update")
    else
      redirect_to unit_event_path(@unit, @event), notice: t("events.edit_rsvps.notices.update")
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
  def perform_cancellation
    service = EventCancellationService.new(@event, event_params)
    redirect_to unit_events_path(@unit), notice: "Event has been cancelled." and return if service.cancel
  end

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
    if (date_s = params[:date]).present?
      @event.starts_at = date_s.to_date
      @event.ends_at = date_s.to_date
    end
    %w[departure arrival activity].each do |location_type|
      @event.event_locations.find_or_initialize_by(location_type: location_type)
    end
    set_default_times
    @member_rsvps = current_member.event_rsvps
  end

  def collate_rsvps
    @non_respondents = @event.unit.members.status_active - @event.rsvps.collect(&:member)
  end

  def destroy_series
    return unless @event.series_parent.present?

    @unit.events.where(series_parent_id: @event.series_parent_id).destroy_all
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
  def event_params
    p = params.require(:event).permit(:title, :event_category_id, :location, :address, :description,
                                      :short_description, :requires_rsvp, :includes_activity, :activity_name,
                                      :all_day, :starts_at_date, :starts_at_time, :ends_at_date, :ends_at_time, :repeats,
                                      :repeats_until, :departs_from, :status, :venue_phone, :message_audience,
                                      :note, :cost_youth, :cost_adult, :online, :website, :tag_list, :rsvp_closes_at,
                                      :notify_members, :notify_recipients, :notify_message, :document_library_ids,
                                      packing_list_ids: [], attachments: [],
                                      event_locations_attributes: [:id, :location_type, :location_id, :event_id, :_destroy],
                                      event_organizers_attributes: [:unit_membership_id])
    p[:packing_list_ids] = p[:packing_list_ids].reject(&:blank?) if p[:packing_list_ids].present?
    process_event_locations_attributes(p)
    process_packlist_ids(p)
  end

  # iterates through event_location_attributes and adds _destroy: true where appropriate
  def process_event_locations_attributes(p)
    return p unless (elas = p[:event_locations_attributes])

    elas.each do |key, value_hash|
      if value_hash[:id] != "" && value_hash[:location_id] == ""
        value_hash[:_destroy] = true
        elas[key] = value_hash
      end
    end
    p[:event_locations_attributes] = elas
    p
  end

  def process_packlist_ids(p)
    p[:packing_list_ids] = p[:packing_list_ids].reject(&:blank?) if p[:packing_list_ids]
    p
  end

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

  def find_next_and_previous_events
    @next_event = @unit.events.published.rsvp_required.where("starts_at > ?", @event.starts_at)&.first
    @previous_event = @unit.events.published.rsvp_required.where("starts_at < ?", @event.starts_at)&.last
  end

  def current_layout
    user_signed_in? ? "application" : "public"
  end

  def prepare_turbo_stream
    starts_at = Date.new(@current_year, @current_month, 1)
    ends_at   = starts_at.end_of_month.end_of_day

    scope = Event.unscoped.includes([event_locations: :location], :tags, :event_category, :event_rsvps)
    scope = scope.where(unit_id: @unit.id)
    scope = scope.where("starts_at BETWEEN ? AND ?", starts_at, ends_at)
    scope = scope.order(starts_at: :asc)
    scope = scope.published unless EventPolicy.new(current_member, @unit).view_drafts?
    @events = scope.all

    next_most_recent_event = Event.unscoped.where("unit_id = ? AND starts_at < ?", @unit.id, starts_at)
                                  .order(starts_at: :desc).first

    @last_month = next_most_recent_event.present? ? next_most_recent_event.starts_at.beginning_of_month : nil
  end

  def remember_unit_events_path
    session[:events_index_path] = request.original_fullpath
  end

  def scope_for_calendar
    scope = @unit.events
    scope = scope.published unless EventPolicy.new(current_member, @unit).view_drafts?
    scope.where("starts_at BETWEEN ? AND ?", @start_date, @end_date)
  end

  def scope_for_list
    scope = @unit.events.includes([event_locations: :location], :tags, :event_category, :event_rsvps)
    scope = if params[:season] == "next"
              scope.where("starts_at BETWEEN ? AND ?", @unit.next_season_starts_at, @unit.next_season_ends_at)
            else
              scope.where("starts_at BETWEEN ? AND ?", @start_date.in_time_zone, @end_date.in_time_zone)
            end
    scope = scope.published unless EventPolicy.new(current_member, @unit).view_drafts?
    scope.order(starts_at: :asc)
  end

  def find_list_events
    scope = @unit.events.future.includes([event_locations: :location], :tags, :event_category, :event_rsvps)
    scope = scope.published unless EventPolicy.new(current_member, @unit).view_drafts?
    scope.order(starts_at: :asc)
    @events = scope.all
  end

  def send_fridge_calendar
    pdf = Pdf::FridgeCalendar.new(@unit, scope_for_list.all)
    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def send_event_brief
    pdf = Pdf::EventBrief.new(@event)
    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def send_ical
    send_data(@event.to_ical, filename: @event.ical_filename, type: "text/calendar", disposition: "inline")
  end

  def set_calendar_dates
    @current_year  = params[:year]&.to_i || Date.today.year
    @current_month = params[:month]&.to_i || Date.today.month
    @display_month = params[:display_month]&.to_i
    @display_year  = params[:display_year]&.to_i
    @start_date    = Date.new(@current_year, @current_month, 1)
    @end_date      = @start_date.end_of_month.end_of_day
    @next_month    = @end_date.next_month.beginning_of_month
    @last_month    = @start_date.prev_month
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/CyclomaticComplexity
