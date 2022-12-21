class AddEventShiftsToEventRsvps < ActiveRecord::Migration[7.0]
  def change
    add_column :event_rsvps, :event_shift_ids, :integer, array: true, default: []
  end
end
