# frozen_string_literal: true

# "online" was modelled as a fourth location_type, but an online event has no
# place in the address book and can't coexist with departure/arrival/activity.
# This moves the URL onto the event and clears the way for location_type to
# become a three-value enum.
#
# Stray location_type values must be normalised in the same pass: once the enum
# lands, any value outside it reads back as nil rather than as the raw string,
# so those rows would silently lose their type.
class PromoteOnlineToEventAttribute < ActiveRecord::Migration[8.0]
  KNOWN_TYPES = %w[departure arrival activity].freeze

  def up
    add_column :events, :online_url, :string unless column_exists?(:events, :online_url)

    say_with_time "moving online location URLs onto events" do
      execute <<~SQL.squish
        UPDATE events SET online_url = el.url
        FROM event_locations el
        WHERE el.event_id = events.id
          AND el.location_type = 'online'
          AND el.url IS NOT NULL
          AND el.url <> ''
      SQL
    end

    # Onlineable previously treated a bare events.website as "online" too, so
    # preserve that behaviour rather than silently taking those events offline
    say_with_time "carrying the website fallback over" do
      execute <<~SQL.squish
        UPDATE events SET online_url = website
        WHERE online_url IS NULL AND website IS NOT NULL AND website <> ''
      SQL
    end

    say_with_time "removing online pseudo-locations" do
      execute "DELETE FROM event_locations WHERE location_type = 'online'"
    end

    normalize_stray_types
  end

  def down
    remove_column :events, :online_url
  end

  private

  def normalize_stray_types
    quoted = KNOWN_TYPES.map { |t| connection.quote(t) }.join(", ")
    strays = select_all(
      "SELECT location_type, COUNT(*) AS n FROM event_locations " \
      "WHERE location_type NOT IN (#{quoted}) GROUP BY location_type"
    ).to_a

    return if strays.empty?

    say "normalising stray location_type values to 'arrival':"
    strays.each { |row| say "#{row["location_type"].inspect} => #{row["n"]} row(s)", true }

    execute "UPDATE event_locations SET location_type = 'arrival' WHERE location_type NOT IN (#{quoted})"
  end
end
