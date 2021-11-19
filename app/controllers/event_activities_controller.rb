# frozen_string_literal: true

# handles Activities, which are children of Events
class EventActivitiesController < ApplicationController
  before_action :find_event, only: [:create, :new]
  before_action :find_activity, only: [:update, :destroy]

  def new
    @activity = @event.activities.new
    respond_to :js
  end

  def update
    ap activity_params
    @activity.assign_attributes(activity_params)
    @activity.save!
  end

  def create
    @activity = @event.activities.new(activity_params)
    @activity.save!
    respond_to :js
  end

  def destroy
    @activity_id = @activity.id
    @activity.destroy
    respond_to :js
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
