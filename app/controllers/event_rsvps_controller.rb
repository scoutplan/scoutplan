# frozen_string_literal: true

# only intended to be called via XHR...no view exist
# for this controller
class EventRsvpsController < ApplicationController
  def create
    @event    = Event.find(params[:event_id])
    @member   = UnitMembership.find(params[:unit_membership_id])
    @response = params[:response]
    @rsvp     = EventRsvp.find_or_create_by(event: @event, unit_membership: @member)

    @rsvp.response = @response
    @rsvp.save!

    @event.reload

    # these two lines are cribbed from Events#organize...DRY it out
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)

    respond_to :js
  end
end
