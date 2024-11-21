# frozen_string_literal: true

class EventLocation < ApplicationRecord
  belongs_to :event
  belongs_to :location, optional: true

  after_save :enqueue_static_map_job

  validates_uniqueness_of :location_type, scope: :event

  def location_name
    url.present? ? url : location&.name
  end

  def enqueue_static_map_job
    GenerateEventStaticMapJob.perform_later(event.id)
  end
end
