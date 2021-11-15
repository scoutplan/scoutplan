class AddNoteToEventRsvp < ActiveRecord::Migration[6.1]
  def change
    add_column :event_rsvps, :note, :string
  end
end
