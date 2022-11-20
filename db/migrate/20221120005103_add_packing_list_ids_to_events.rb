class AddPackingListIdsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :packing_list_ids, :integer, array: true, default: []
  end
end
