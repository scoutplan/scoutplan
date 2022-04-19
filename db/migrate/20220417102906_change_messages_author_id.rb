class ChangeMessagesAuthorId < ActiveRecord::Migration[7.0]
  def change
    rename_column :messages, :unit_membership_id, :author_id
  end
end
