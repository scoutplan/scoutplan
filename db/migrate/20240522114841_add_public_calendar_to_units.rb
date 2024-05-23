class AddPublicCalendarToUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :units, :public_calendar, :boolean, default: false
  end
end
