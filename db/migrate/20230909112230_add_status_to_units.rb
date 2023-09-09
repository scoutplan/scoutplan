class AddStatusToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :status, :string, default: "active"
  end
end
