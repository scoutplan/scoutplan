class RenameMessageRecipientsToAudience < ActiveRecord::Migration[7.0]
  def change
    rename_column :messages, :recipients, :audience
  end
end
