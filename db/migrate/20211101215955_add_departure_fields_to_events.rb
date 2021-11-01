class AddDepartureFieldsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :departs_from, :string
  end
end
