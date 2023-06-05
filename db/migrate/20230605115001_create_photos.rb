class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.integer :unit_id, null: false
      t.integer :event_id, null: true
      t.string :caption, null: true
      t.text :description, null: true
      t.integer :author_id, null: false

      t.timestamps
    end
  end
end
