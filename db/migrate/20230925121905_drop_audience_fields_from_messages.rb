class DropAudienceFieldsFromMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :audience
    remove_column :messages, :member_type
    remove_column :messages, :member_status
  end
end
