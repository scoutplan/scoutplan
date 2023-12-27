class DropEventInvitations < ActiveRecord::Migration[7.1]
  def change
    drop_table :event_invitations
  end
end
