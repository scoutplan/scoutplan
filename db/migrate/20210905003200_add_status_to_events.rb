# frozen_string_literal: true

class AddStatusToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :status, :integer, default: 0
  end
end
