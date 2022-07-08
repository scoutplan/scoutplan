class AddRecipientsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :recipients, :string
  end
end
