class CreateEventLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :event_locations do |t|
      t.integer :event_id, null: false
      t.integer :location_id, null: false
      t.string :key, null: false

      t.timestamps
    end
  end
end
