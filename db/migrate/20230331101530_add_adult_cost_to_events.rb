class AddAdultCostToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :cost_adult, :integer, default: 0
    rename_column :events, :payment_amount, :cost_youth
  end
end
