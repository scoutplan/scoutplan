# frozen_string_literal: true

# rsvp_closes_at was somehow defined as a String, which is wrong.
# This fixes that.
class ChangeRsvpClosesAtToDatetime < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :rsvp_closes_at
    add_column :events, :rsvp_closes_at, :datetime
  end
end
