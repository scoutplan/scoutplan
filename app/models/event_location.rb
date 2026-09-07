# frozen_string_literal: true

class EventLocation < ApplicationRecord
  # declaration order is the display order: you depart, you arrive, you do the
  # thing. "online" is deliberately absent - it lives on Event#online_url.
  # validate: true keeps a bad value out of the database without raising, so a
  # malformed request is a 422 rather than a 500.
  enum :location_type,
    {departure: "departure", arrival: "arrival", activity: "activity"},
    validate: true

  belongs_to :event
  belongs_to :location, optional: true

  after_commit :enqueue_event_static_map

  scope :in_display_order, -> { in_order_of(:location_type, location_types.keys) }

  def location_name
    url.present? ? url : location&.name
  end

  private

  # one map per event, not one per location: nested attributes save every child
  # through the same in-memory Event, so the memo collapses them
  def enqueue_event_static_map
    event.enqueue_static_map_job_once
  end
end
