# frozen_string_literal: true

class CreateEventCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :event_categories do |t|
      t.integer :unit_id
      t.string :name
      t.string :glyph
      t.string :color

      t.timestamps
    end

    remove_column :events, :category, :string
    add_column :events, :event_category_id, :integer
  end
end
