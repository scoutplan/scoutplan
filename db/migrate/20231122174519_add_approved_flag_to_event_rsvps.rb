class AddApprovedFlagToEventRsvps < ActiveRecord::Migration[7.0]
  def change
    add_column :event_rsvps, :approved, :boolean, default: false, null: false
  end
end
