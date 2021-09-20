# frozen_string_literal: true

# only intended to be called via XHR...no view exist
# for this controller
class EventRsvpsController < ApplicationController
  def create
    @event = Event.find(params[:event_id])

    # these two lines are cribbed from Events#organize...DRY it out
    @non_respondents = @event.rsvp_tokens.collect(&:user) - @event.rsvps.collect(&:user)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:user) - @event.rsvps.collect(&:user)

    @user = User.find(params[:user_id])
    @response = params[:response]
    @rsvp = EventRsvp.find_or_create_by(event: @event, user: @user)
    @rsvp.response = @response
    @rsvp.save!

    respond_to :html, :json, :js
  end
end
