# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[6.1]
  def change
    create_table :units do |t|
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
