class AddSlugToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :slug, :string, unique: true
  end
end
