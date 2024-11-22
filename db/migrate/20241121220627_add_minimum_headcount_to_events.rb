class AddMinimumHeadcountToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :min_headcount_adult, :integer
    add_column :events, :min_headcount_youth, :integer
  end
end
