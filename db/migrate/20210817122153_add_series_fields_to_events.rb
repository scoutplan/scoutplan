class AddSeriesFieldsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :series_parent_id, :integer
  end
end
