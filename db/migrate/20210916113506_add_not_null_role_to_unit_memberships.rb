class AddNotNullRoleToUnitMemberships < ActiveRecord::Migration[6.1]
  def change
    UnitMembership.where(role: nil).update_all(role: 'member')
    change_column_null :unit_memberships, :role, false
  end
end
