# frozen_string_literal: true

# only intended to be called via XHR...no view exist
# for this controller
class EventRsvpsController < ApplicationController
  def update
    @rsvp = EventRsvp.find(params[:id])
    @rsvp.update!(event_rsvp_params)

    respond_to do |format|
      format.js
    end
  end

  private

  def event_rsvp_params
    params.require(:event_rsvp).permit(:response)
  end
end
