class AddDescriptionToPackingListItems < ActiveRecord::Migration[7.0]
  def change
    add_column :packing_list_items, :description, :text
  end
end
