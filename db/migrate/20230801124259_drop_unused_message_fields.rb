class DropUnusedMessageFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :recipient_details
    remove_column :messages, :deliver_via_digest
    remove_column :messages, :deliver_via_notification
    remove_column :messages, :include_in_digest
    remove_column :messages, :pin_until
    remove_column :messages, :notify_recipients
  end
end
