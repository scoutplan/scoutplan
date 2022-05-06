class AddReminderFlagToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :send_reminder, :boolean, null: false, default: true
  end
end
