# frozen_string_literal: true

class GenerateEventStaticMapJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find(event_id)
    event.generate_static_map
  end
end
