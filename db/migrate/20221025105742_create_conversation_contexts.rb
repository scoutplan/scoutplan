class CreateConversationContexts < ActiveRecord::Migration[7.0]
  def change
    create_table :conversation_contexts do |t|
      t.string :identifier
      t.string :values

      t.timestamps
    end
  end
end
