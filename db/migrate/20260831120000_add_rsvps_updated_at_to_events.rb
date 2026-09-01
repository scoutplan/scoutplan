# frozen_string_literal: true

# RSVP activity used to be recorded by `EventRsvp belongs_to :event, touch: true`, which moved
# events.updated_at. Three jobs read that column as a staleness guard, so every RSVP scheduled a
# duplicate reminder that later bailed, and every RSVP contended on the event row. This column
# carries the same signal for cache keys while leaving updated_at to mean "an organizer edited
# this event".
class AddRsvpsUpdatedAtToEvents < ActiveRecord::Migration[8.0]
  def up
    add_column :events, :rsvps_updated_at, :datetime

    # Seed from the newest RSVP where there is one, falling back to the event's own timestamp, so
    # existing cache keys start out stable rather than all-nil.
    execute <<~SQL.squish
      UPDATE events
         SET rsvps_updated_at = COALESCE(
               (SELECT MAX(event_rsvps.updated_at)
                  FROM event_rsvps
                 WHERE event_rsvps.event_id = events.id),
               events.updated_at)
    SQL
  end

  def down
    remove_column :events, :rsvps_updated_at
  end
end
