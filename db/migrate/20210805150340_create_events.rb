class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.integer :unit_id
      t.string :title
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :location
      t.string :category

      t.timestamps
    end
  end
end
