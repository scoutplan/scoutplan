class AddContactabilityFlagsToUnitMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :unit_memberships, :contactable_via_email, :boolean, default: false, null: false
    add_column :unit_memberships, :contactable_via_sms, :boolean, default: false, null: false
    add_column :unit_memberships, :contactable, :boolean, default: false, null: false
  end
end
