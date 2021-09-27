# frozen_string_literal: true

# only intended to be called via XHR...no view exist
# for this controller
class EventRsvpsController < ApplicationController
  def create
    @event    = Event.find(params[:event_id])
    @member   = UnitMembership.find(params[:member_id])
    @response = params[:response]
    @rsvp     = EventRsvp.find_or_create_by(event: @event, unit_membership: @member)

    @rsvp.response = @response
    @rsvp.save!

    @event.reload

    find_event_responses
    respond_to :js
  end

  # send or re-send an invitation
  def invite
    @event = Event.find(params[:id])
    @member = UnitMembership.find(params[:member_id])
    @token  = @event.rsvp_tokens.create!(unit_membership: @member)
    EventNotifier.invite_member_to_event(@token)
    find_event_responses
    respond_to :js
  end

  private

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end
