class CreateMessageRecipients < ActiveRecord::Migration[7.0]
  def change
    create_table :message_recipients do |t|
      t.string :message_receivable_type
      t.string :message_receivable_id
      t.integer :message_id

      t.timestamps
    end
  end
end
