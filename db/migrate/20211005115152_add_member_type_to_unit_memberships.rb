class AddMemberTypeToUnitMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column :unit_memberships, :member_type, :integer, default: 0
  end
end
