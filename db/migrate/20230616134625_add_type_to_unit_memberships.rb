class AddTypeToUnitMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_memberships, :type, :string, null: false, default: "UnitMembership"
  end
end
