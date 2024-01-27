class AddRosterDisplayOptionsToUnitMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :unit_memberships, :roster_display_phone, :boolean, default: false
    add_column :unit_memberships, :roster_display_email, :boolean, default: false
  end
end
