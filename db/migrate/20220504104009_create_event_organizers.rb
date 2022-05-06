class CreateEventOrganizers < ActiveRecord::Migration[7.0]
  def change
    create_table :event_organizers do |t|
      t.integer :event_id
      t.integer :unit_membership_id
      t.string :role, null: false, default: "organizer"

      t.timestamps
    end
  end
end
