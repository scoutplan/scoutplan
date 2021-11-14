class AddEquipmentToEventActivity < ActiveRecord::Migration[6.1]
  def change
    add_column :event_activities, :equipment, :text, array: true, default: []
  end
end
