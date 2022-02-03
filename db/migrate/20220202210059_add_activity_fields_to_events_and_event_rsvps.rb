class AddActivityFieldsToEventsAndEventRsvps < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :includes_activity, :boolean, null: false, default: false
    add_column :events, :activity_name, :string
    add_column :event_rsvps, :includes_activity, :boolean, null: false, default: false
  end
end
