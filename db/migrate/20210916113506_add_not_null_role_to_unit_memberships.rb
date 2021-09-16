class AddNotNullRoleToUnitMemberships < ActiveRecord::Migration[6.1]
  def change
    UnitMembership.where(role: nil).update_all(role: 'member')
    UnitMembership.where(status: nil).update_all(status: :active)
    change_column_null :unit_memberships, :role, false
    change_column_null :unit_memberships, :status, false
  end
end
