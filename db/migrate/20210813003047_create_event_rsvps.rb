class CreateEventRsvps < ActiveRecord::Migration[6.1]
  def change
    create_table :event_rsvps do |t|
      t.integer :event_id
      t.integer :user_id
      t.integer :response

      t.timestamps
    end
  end
end
