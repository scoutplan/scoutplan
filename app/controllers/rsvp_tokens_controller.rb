# frozen_string_literal: true

# this non-restful controller intercepts "passwordless" RSVPs,
# typically from email links

class RsvpTokensController < ApplicationController
  skip_before_action :authenticate_user!

  def login
    # resolve the token to an invitation
    @rsvp_token = RsvpToken.find_by(value: params[:id])
    session[:via_magic_link] = true

    # resolve invitation to event and user
    @event = @rsvp_token.event
    @user  = @rsvp_token.user

    # sign the user in and redirect to the event page
    flash[:notice] = t('passwordless_warning')
    sign_in @user
    redirect_to event_path(@event, anchor: 'rsvp')
  end
end
