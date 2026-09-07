# frozen_string_literal: true

# Event#online? used to be derived from the presence of a URL. It now reads the
# events.online boolean, so that an organiser can mark an event online before
# they have the Zoom link. Existing online events carry a URL but a false flag.
class BackfillEventsOnlineFlag < ActiveRecord::Migration[8.0]
  def up
    say_with_time "flagging events that already have an online URL" do
      execute <<~SQL.squish
        UPDATE events SET online = true
        WHERE online_url IS NOT NULL AND online_url <> ''
      SQL
    end
  end

  def down
    execute "UPDATE events SET online = false"
  end
end
