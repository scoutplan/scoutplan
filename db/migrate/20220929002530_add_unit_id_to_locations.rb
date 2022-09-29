class AddUnitIdToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :unit_id, :integer
  end
end
