class AddCohortNameToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :cohort_name, :string, null: true, default: nil
  end
end
