class CreateEventShifts < ActiveRecord::Migration[7.0]
  def change
    create_table :event_shifts do |t|
      t.integer :event_id
      t.string :name

      t.timestamps
    end
  end
end
