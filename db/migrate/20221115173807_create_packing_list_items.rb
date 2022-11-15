class CreatePackingListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :packing_list_items do |t|
      t.integer :packing_list_id
      t.string :name

      t.timestamps
    end
  end
end
