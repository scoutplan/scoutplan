# frozen_string_literal: true

# migration to create Task schema
class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string      :key, null: false
      t.text        :schedule_hash
      t.string      :type, null: false
      t.datetime    :last_ran_at
      t.references  :taskable, null: false, polymorphic: true
      t.timestamps
    end
  end
end