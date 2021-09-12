# frozen_string_literal: true

class CreateRsvpTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :rsvp_tokens do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :value
      t.datetime :expires_at

      t.timestamps
    end
  end
end
