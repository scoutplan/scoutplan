class CreateEventInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :event_invitations do |t|
      t.integer :event_id, null: false
      t.integer :unit_membership_id, null: false
      t.string :method, null: false, default: "email"
      t.timestamps
    end
  end
end
