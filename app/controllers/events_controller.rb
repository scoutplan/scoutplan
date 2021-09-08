class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_unit, only: [ :index, :create, :new ]
  before_action :find_event, except: [ :index, :edit, :create, :new ]

  def index
    @events = UnitEventQuery.new(@unit, @membership).execute
    build_prototype_event
  end

  def show
    authorize @event
    @rsvps = @event.event_rsvps.where(user: current_user)
    @can_edit = policy(@event).edit?
    @can_organize = policy(@event).organize?
  end

  def create
    authorize :event, :create?

    @event = @unit.events.new(event_params)
    @event.starts_at = ScoutplanUtilities.compose_datetime(params[:starts_at_d], params[:starts_at_t])
    @event.ends_at   = ScoutplanUtilities.compose_datetime(params[:ends_at_d], params[:ends_at_t])

    # dynamically add a new attribute to signal this is a series parent
    # the object hooks will take care of generating the series
    if params[:event_repeats] == 'on' && end_date = Date.strptime(params[:repeats_until], '%Y-%m-%d')
      class << @event
        attr_accessor :repeats_until
      end
      @event.repeats_until = end_date
    end

    if @event.save!
      flash[:notice] = t('helpers.label.event.create_confirmation', event_name: @event.title)
      redirect_to @event
    end
  end

  def edit
    authorize @event
  end

  def organize
    authorize @event
    @non_respondents = @event.unit.members - @event.rsvps.collect(&:user)
  end

  def rsvp
    flash[:toast] = t(:rsvp_posted)
    redirect_to [@unit, @event]
  end

  # this override is needed to pass the membership instead of the user
  # as the object to be evaluated in Pundit policies
  def pundit_user
    @membership
  end

private

  def build_prototype_event
    @event = @unit.events.new(
      starts_at: 28.days.from_now,
      ends_at: 28.days.from_now
    )
    @event.starts_at = @event.starts_at.change({ hour: 10 }) # default starts at 10 AM
    @event.ends_at   = @event.ends_at.change({ hour: 16 }) # default ends at 4 PM
    @user_rsvps = current_user.event_rsvps
  end

  # we don't guarantee that @unit is populated, hence...
  # @display_unit is used for global nav and other common
  # elements where unit is needed

  # for index, new, and create
  def find_unit
    @unit = Unit.find(params[:unit_id])
    @display_unit = @unit
    @membership = @display_unit.membership_for(current_user)
  end

  # for show, edit, update, destroy...important that @unit
  # is *not* set for those actions
  def find_event
    @event = Event.find(params[:id])
    @display_unit = @event.unit
    @membership = @event.unit.membership_for(current_user)
    @presenter = EventPresenter.new(@event)
  end

  # permitted parameters
  def event_params
    params.require(:event).permit(
      :title,
      :event_category_id,
      :location,
      :description,
      :requires_rsvp,
      :starts_at_d,
      :starts_at_t,
      :ends_at_d,
      :ends_at_t,
    )
  end

  # create a weekly series based on @event
  def create_series(end_date_str)
    end_date = Date.strptime(end_date_str, '%Y-%m-%d')
    new_event = @event.dup
    new_event.series_parent = @event

    while new_event.starts_at < end_date
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end

  # if RSVPs are needed, spin up a token for each active user
  def create_magic_links
    @unit.members.active.each { |user| RsvpToken.create(user: user, event: event) }
  end
end
