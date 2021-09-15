# frozen_string_literal: true

# add repeats_until to Event class
class AddRepeatsUntilToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :repeats_until, :date
  end
end
