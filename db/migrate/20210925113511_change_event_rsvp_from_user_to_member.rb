class ChangeEventRsvpFromUserToMember < ActiveRecord::Migration[6.1]
  def change
    add_column :event_rsvps, :unit_membership_id, :integer
    remove_column :event_rsvps, :user_id, :integer
  end
end
