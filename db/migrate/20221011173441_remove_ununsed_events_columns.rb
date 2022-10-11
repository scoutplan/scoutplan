class RemoveUnunsedEventsColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :departs_from, :string
    remove_column :events, :venue_phone, :string
    remove_column :events, :location, :string
    remove_column :events, :address, :string
    remove_column :events, :phone, :string
  end
end
