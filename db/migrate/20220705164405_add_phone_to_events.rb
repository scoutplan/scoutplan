class AddPhoneToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :phone, :string
  end
end
