class AddReceivedByAndMethodToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :received_by_id, :integer
    add_column :payments, :method, :string, default: "other"
  end
end
