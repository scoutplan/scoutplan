# frozen_string_literal: true

# Real coordinate columns, so map rendering can stop geocoding an address string
# at request time and so a lookup/autocomplete has somewhere to put its answer.
#
# Coordinates already existed in the data model informally: map_name is
# documented as "Name as it appears on maps", but LocationsHelper#coordinates?
# also matches a "lat,lng" pair pasted into that field. Those get lifted into
# the real columns here. The original string is left alone, since other code
# reads map_name for display and this migration should not change what is shown.
class AddCoordinatesToLocations < ActiveRecord::Migration[8.0]
  COORDINATE_PATTERN = '^\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*$'

  def up
    add_column :locations, :latitude, :decimal, precision: 10, scale: 6
    add_column :locations, :longitude, :decimal, precision: 10, scale: 6

    say_with_time "lifting coordinate pairs out of map_name" do
      execute <<~SQL.squish
        UPDATE locations
        SET latitude  = trim(split_part(map_name, ',', 1))::decimal,
            longitude = trim(split_part(map_name, ',', 2))::decimal
        WHERE map_name ~ '#{COORDINATE_PATTERN}'
      SQL
    end
  end

  def down
    remove_column :locations, :latitude
    remove_column :locations, :longitude
  end
end
