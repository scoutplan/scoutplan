class CreatePaymentAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_accounts do |t|
      t.integer :unit_id
      t.string :account_id

      t.timestamps
    end
  end
end
