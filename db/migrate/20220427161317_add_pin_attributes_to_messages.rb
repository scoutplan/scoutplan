class AddPinAttributesToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :pin_until, :date
    add_column :messages, :include_in_digest, :boolean, default: false
    add_column :messages, :notify_recipients, :boolean, default: false
  end
end
