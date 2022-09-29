class RenameEventLocationsKeyField < ActiveRecord::Migration[7.0]
  def change
    rename_column :event_locations, :key, :location_type
  end
end
