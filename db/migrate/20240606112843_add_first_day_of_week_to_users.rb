class AddFirstDayOfWeekToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_day_of_week, :integer, default: 0, null: false
  end
end
