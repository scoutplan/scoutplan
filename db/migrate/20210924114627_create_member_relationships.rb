class CreateMemberRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :member_relationships do |t|
      t.integer :parent_unit_membership_id
      t.integer :child_unit_membership_id

      t.timestamps
    end
  end
end
