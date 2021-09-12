# frozen_string_literal: true

class AddRsvpFieldsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :requires_rsvp, :boolean, default: false
    add_column :events, :rsvp_closes_at, :string
    add_column :events, :max_total_attendees, :integer
    add_column :events, :rsvp_opens_at, :string
  end
end
