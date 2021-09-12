# frozen_string_literal: true

class CreateUnitMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :unit_memberships do |t|
      t.integer :unit_id
      t.integer :user_id
      t.integer :status

      t.timestamps
    end
  end
end
