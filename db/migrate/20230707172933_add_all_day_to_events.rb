class AddAllDayToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :all_day, :boolean, default: false
  end
end
