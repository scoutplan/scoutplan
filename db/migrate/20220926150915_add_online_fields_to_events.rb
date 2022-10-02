class AddOnlineFieldsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :online, :boolean, null: false, default: false
    add_column :events, :website, :string
  end
end
