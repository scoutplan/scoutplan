# frozen_string_literal: true

class AddRoleToUnitMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column :unit_memberships, :role, :string
  end
end
