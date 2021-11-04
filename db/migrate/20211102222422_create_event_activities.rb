class CreateEventActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :event_activities do |t|
      t.integer :event_id
      t.integer :position
      t.string :title

      t.timestamps
    end
  end
end
