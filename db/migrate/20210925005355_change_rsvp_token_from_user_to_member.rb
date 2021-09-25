class ChangeRsvpTokenFromUserToMember < ActiveRecord::Migration[6.1]
  def change
    RsvpToken.destroy_all
    remove_column :rsvp_tokens, :user_id, :integer
    add_column :rsvp_tokens, :unit_membership_id, :integer, null: false
  end
end
