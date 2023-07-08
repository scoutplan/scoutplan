class AddAssignedByIdToEventOrganizers < ActiveRecord::Migration[7.0]
  def change
    add_column :event_organizers, :assigned_by_id, :integer
  end
end
