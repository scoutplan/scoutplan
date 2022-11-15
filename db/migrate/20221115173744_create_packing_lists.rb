class CreatePackingLists < ActiveRecord::Migration[7.0]
  def change
    create_table :packing_lists do |t|
      t.integer :unit_id
      t.string :name

      t.timestamps
    end
  end
end
