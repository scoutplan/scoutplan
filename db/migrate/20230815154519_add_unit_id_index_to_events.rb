class AddUnitIdIndexToEvents < ActiveRecord::Migration[7.0]
  def change
    add_index :events, :unit_id
  end
end
