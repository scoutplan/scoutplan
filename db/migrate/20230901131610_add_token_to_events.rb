class AddTokenToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :token, :string
    add_index :events, :token, unique: true
  end
end
