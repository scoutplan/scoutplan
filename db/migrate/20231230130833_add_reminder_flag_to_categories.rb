class AddReminderFlagToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :event_categories, :send_reminders, :boolean, default: true
  end
end
