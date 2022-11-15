class AddPreferencesToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :unit_memberships, :preferences, :jsonb, null: false, default: {}
  end
end
