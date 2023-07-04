class AddOrganizerNotesToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :organizer_notes, :text
  end
end
