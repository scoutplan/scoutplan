class CreateUnitMembershipRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :unit_membership_requests do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.integer :unit_id

      t.timestamps
    end
  end
end
