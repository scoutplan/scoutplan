class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :phone
      t.integer :locatable_id
      t.string :locatable_type
      t.string :key

      t.timestamps
    end
  end
end
