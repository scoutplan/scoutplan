class ChangeRsvpOpensAtToDate < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :rsvp_opens_at
    add_column :events, :rsvp_opens_at, :datetime
  end
end
