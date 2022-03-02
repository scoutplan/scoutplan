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
end
