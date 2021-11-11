# frozen_string_literal: true

# handles Activities, which are children of Events
class EventActivitiesController < ApplicationController
  before_action :find_event, only: [:create, :new]

  def new
    @activity = @event.activities.new
    respond_to :js
  end
  
  def update
    ap params
  end

  def create
    @activity = @event.activities.new(activity_params)
    @activity.save!
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
