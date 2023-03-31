class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :unit_membership_id
      t.integer :event_id
      t.integer :amount
      t.string :stripe_id
      t.string :stripe_status

      t.timestamps
    end
  end
end
