class CreateDocumentTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :document_types do |t|
      t.string :documentable_type, null: false
      t.integer :documentable_id, null: false
      t.string :description, null: false
      t.boolean :required, null: false, default: true

      t.timestamps
    end
  end
end
