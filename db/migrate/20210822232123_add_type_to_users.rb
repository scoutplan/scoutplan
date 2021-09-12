# frozen_string_literal: true

class AddTypeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :type, :string
  end
end
