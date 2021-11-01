class AddShortDescriptionToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :short_description, :text
  end
end
