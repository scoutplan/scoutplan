class AddTransactionFeeOptionToPaymentAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_accounts, :transaction_fees_covered_by, :string, default: "member"
  end
end
