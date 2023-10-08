class RemovePolymorphismFromMessageRecipient < ActiveRecord::Migration[7.0]
  def change
    remove_column :message_recipients, :message_receivable_type
    remove_column :message_recipients, :message_receivable_id
    add_column :message_recipients, :unit_membership_id, :integer
  end
end
