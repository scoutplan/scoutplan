class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :documentable_type
      t.integer :documentable_id
      t.integer :document_type_id

      t.timestamps
    end
  end
end
