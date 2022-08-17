class AddPaymentAmountToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :payment_amount, :integer, null: false, default: 0
  end
end
