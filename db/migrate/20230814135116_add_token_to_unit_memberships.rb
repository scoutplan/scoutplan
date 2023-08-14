class AddTokenToUnitMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_memberships, :token, :string
  end
end
