class AddIcalSuppressDeclinedToUnitMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :unit_memberships, :ical_suppress_declined, :boolean, default: false, null: false
  end
end
