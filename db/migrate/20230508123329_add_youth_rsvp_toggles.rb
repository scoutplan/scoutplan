class AddYouthRsvpToggles < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :allow_youth_rsvps, :boolean, default: false
    add_column :unit_memberships, :allow_youth_rsvps, :boolean, default: false
    add_column :events, :allow_youth_rsvps, :boolean, default: true
  end
end
