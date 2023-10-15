# frozen_string_literal: true

class EventLocation < ApplicationRecord
  belongs_to :event
  belongs_to :location
  validates_uniqueness_of :location_type, scope: [:event, :location]

  after_save :enqueue_static_map_job

  def enqueue_static_map_job
    GenerateEventStaticMapJob.perform_later(event.id)
  end
end
