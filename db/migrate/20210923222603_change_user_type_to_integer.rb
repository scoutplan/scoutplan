class ChangeUserTypeToInteger < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :type
    add_column :users, :type, :integer, default: 0, null: false
  end
end
