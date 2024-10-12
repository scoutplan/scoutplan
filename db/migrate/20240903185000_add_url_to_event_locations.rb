class AddUrlToEventLocations < ActiveRecord::Migration[7.1]
  def change
    add_column :event_locations, :url, :string, null: true
    change_column_null :event_locations, :location_id, true
  end
end
