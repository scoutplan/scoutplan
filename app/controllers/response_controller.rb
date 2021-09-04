# this non-restful controller intercepts "passwordless" RSVPs,
# typically from email links

class ResponseController < ApplicationController
  skip_before_action :authenticate_user!

  def handle
    # resolve the token to an invitation
    @rsvp_token = RsvpToken.find_by(value: params[:id])

    # resolve invitation to event and user
    @event = @rsvp_token.event
    @unit  = @event.unit
    @user  = @rsvp_token.user

    # sign the user in and redirect to the event page
    flash[:notice] = t('passwordless_warning')
    sign_in @user
    redirect_to unit_event_path(@unit, @event, anchor: 'rsvp')
  end
end
