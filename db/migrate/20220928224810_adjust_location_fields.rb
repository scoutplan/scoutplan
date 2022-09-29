class AdjustLocationFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :locatable_type, :string
    remove_column :locations, :locatable_id, :integer
    remove_column :locations, :key, :string
    remove_column :locations, :city, :string
    remove_column :locations, :state, :string
    remove_column :locations, :postal_code, :string
    add_column :locations, :map_name, :string
  end
end
