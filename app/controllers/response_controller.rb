# this non-restful controller intercepts "passwordless" RSVPs,
# typically from email links

class ResponseController < ApplicationController
  skip_before_action :authenticate_user!

  def handle
    # resolve the token to an invitation
    # resolve invitation to event and user
    # sign_in_and_redirect_to user, unit_event_path(unit, event, anchor: 'rsvp')
    flash[:notice] = t('passwordless_warning')
    redirect_to root_path
  end
end
