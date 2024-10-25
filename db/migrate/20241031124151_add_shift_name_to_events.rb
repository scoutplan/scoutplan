class AddShiftNameToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :shift_name, :string, default: "Time slots"
  end
end
