class AddPaidToEventRsvps < ActiveRecord::Migration[7.0]
  def change
    add_column :event_rsvps, :paid, :boolean, default: false, null: false
  end
end
