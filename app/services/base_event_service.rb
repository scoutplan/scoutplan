# frozen_string_literal: true

# abstract class for deriving Services that deal with Events
class BaseEventService < ApplicationService
  def initialize(event, params = {})
    @event = event
    @params = params
    super()
  end
end
