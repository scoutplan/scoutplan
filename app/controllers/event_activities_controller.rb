# frozen_string_literal: true

# handles Activities, which are children of Events
class EventActivitiesController < ApplicationController
  before_action :find_event
  before_action :find_activity, only: %i[update destroy]
  layout false

  def index; end

  def new
    @activity = @event.activities.new
  end

  def update
    @activity.assign_attributes(activity_params)
    @activity.save!
  end

  def create
    @activity = @event.activities.new(activity_params)
    @activity.save!
    redirect_to unit_event_event_activities_path(@event.unit, @event)
  end

  def destroy
    @activity.destroy
    redirect_to unit_event_event_activities_path(@event.unit, @event)
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_activity
    @activity = EventActivity.find(params[:id])
  end

  def activity_params
    params.require(:event_activity).permit(:position, :event_id, :title)
  end
end
