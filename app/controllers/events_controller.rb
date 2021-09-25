# frozen_string_literal: true

require 'humanize'

# controller for Events
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_unit, only: %i[index create new bulk_publish]
  before_action :find_event, except: %i[index edit create new bulk_publish]

  def index
    @events = UnitEventQuery.new(@unit, @current_member).execute
    @presenter = EventPresenter.new
    @current_family = @current_member.family
    @current_year = @current_month = nil
    build_prototype_event
  end

  def show
    authorize @event
    @can_edit = policy(@event).edit?
    @can_organize = policy(@event).organize?
    @current_family = @current_member.family
  end

  def create
    authorize :event, :create?
    @event = @unit.events.new(event_params)
    @event.starts_at = ScoutplanUtilities.compose_datetime(params[:starts_at_d], params[:starts_at_t])
    @event.ends_at   = ScoutplanUtilities.compose_datetime(params[:ends_at_d], params[:ends_at_t])
    @event.repeats_until = nil unless params[:event_repeats] == 'on'
    return unless @event.save!

    flash[:notice] = t('helpers.label.event.create_confirmation', event_name: @event.title)
    redirect_to @event
  end

  def edit
    authorize @event
  end

  def update
    return unless @event.update!(event_params)

    params[:notice] = t('events.update_confirmation', title: @event.title)
    redirect_to @event
  end

  def organize
    authorize @event
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end

  def publish
    authorize @event
    return if @event.published? # don't publish it twice

    @event.update!(status: :published)
    EventNotifier.after_publish(@event)
    flash[:notice] = t('events.publish_message', title: @event.title)
    redirect_to @event
  end

  # POST /units/:id/events/bulk_publish
  def bulk_publish
    event_ids = params[:events]
    events    = Event.find(event_ids)
    count     = events.count

    events.each do |event|
      event.update!(status: :published)
    end

    EventNotifier.after_bulk_publish(@unit, events)

    flash[:notice] = format('%<count>s %<object>s %<be>s %<action>s',
                            count: count.humanize.capitalize,
                            object: t('events.object_name').pluralize(count),
                            be: t('be_verb.past_tense.third_person').pluralize(count),
                            action: t('events.index.bulk_publish.verb'))

    redirect_to unit_events_path(@unit)
  end

  def invite
    event  = Event.find(params[:id])
    member = UnitMembership.find(params[:member_id])
    token  = event.rsvp_tokens.create(unit_membership: member)
    EventNotifier.invite_member_to_event(member, event, token)
  end

  # PATCH /events/:id/rsvpp
  def rsvp
    params[:event][:members].each do |member_id, values|
      response = values[:event_rsvp][:response]
      rsvp = @event.rsvps.create_with(response: response).find_or_create_by!(unit_membership_id: member_id)
      rsvp.update!(response: response)
    end

    flash[:notice] = t(:rsvp_posted)
    redirect_to [@unit, @event]
  end

  # POST cancel
  def cancel
    @event.status = :cancelled

    return unless @event.save!

    flash[:notice] = t('events.show.cancel.confirmation', event_title: @event.title)
    redirect_to unit_events_path(@event.unit)
  end

  # this override is needed to pass the membership instead of the user
  # as the object to be evaluated in Pundit policies
  def pundit_user
    @current_member
  end

  def body_classes
    content_for :body_classes do
      'balh'
    end
  end

  private

  def build_prototype_event
    @event = @unit.events.new(
      starts_at: 28.days.from_now,
      ends_at: 28.days.from_now
    )
    @event.starts_at = @event.starts_at.change({ hour: 10 }) # default starts at 10 AM
    @event.ends_at   = @event.ends_at.change({ hour: 16 }) # default ends at 4 PM
    @member_rsvps    = @current_member.event_rsvps
  end

  # we don't guarantee that @unit is populated, hence...
  # @display_unit is used for global nav and other common
  # elements where unit is needed

  # for index, new, and create
  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
  end

  # for show, edit, update, destroy...important that @unit
  # is *not* set for those actions
  def find_event
    @event = Event.includes(:event_rsvps).find(params[:id])
    @current_unit = @event.unit
    @current_member = @current_unit.membership_for(current_user)
    @presenter = EventPresenter.new(event: @event, current_user: current_user)
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
      :repeats_until
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
