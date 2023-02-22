class AddEmailToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :email, :string
  end
end
