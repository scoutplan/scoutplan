# frozen_string_literal: true

class AddSeriesFieldsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :series_parent_id, :integer
  end
end
