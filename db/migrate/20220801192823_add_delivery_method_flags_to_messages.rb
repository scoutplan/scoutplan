class AddDeliveryMethodFlagsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :deliver_via_digest, :boolean, default: false
    add_column :messages, :deliver_via_notification, :boolean, default: true
  end
end
