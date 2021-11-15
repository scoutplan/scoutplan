class AddRespondentToEventRsvp < ActiveRecord::Migration[6.1]
  def change
    add_column :event_rsvps, :respondent_id, :integer
  end
end
