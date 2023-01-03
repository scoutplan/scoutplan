class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.string :chattable_type
      t.integer :chattable_id

      t.timestamps
    end
  end
end
