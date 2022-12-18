# frozen_string_literal: true

# abstract class for deriving Services that deal with Events
# we're calling it BaseEventService for now because we already
# have another thing called EventService. We'll need to refactor
# that mess.
class EventService < ApplicationService
  def initialize(event, params = {})
    @event = event
    @params = params
    super()
  end

  def process_event_shifts
    return unless @params[:event_shifts].present?
    
    @params[:event_shifts].each do |shift_name|
      event_shift = @event.event_shifts.find_or_create_by(name: shift_name)
      event_shift.save!
    end
  end
end
