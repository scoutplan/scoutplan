class AddVenuePhoneToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :venue_phone, :string
  end
end
