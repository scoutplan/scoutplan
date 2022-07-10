class AddMemberTypeAndRecipientDetailsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :member_type, :string
    add_column :messages, :recipient_details, :string
  end
end
