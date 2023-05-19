class AddParentEventIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :parent_event_id, :integer, null: true
  end
end
