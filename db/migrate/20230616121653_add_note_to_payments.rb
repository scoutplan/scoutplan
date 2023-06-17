class AddNoteToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :note, :text, null: true
  end
end
