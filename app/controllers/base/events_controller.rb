#frozen_string_literal: true

# this is a workaround to support /events/:id
# eventually we should refactor all the /u/ routes into a
# namespace and demote this controller to root /
module Base
  class EventsController < ApplicationController
    def show
      event = Event.find(params[:id])
      redirect_to unit_event_path(event.unit, event)
    end
  end
end
