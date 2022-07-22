class RenameDocumentTypePolymorphicColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :document_types, :documentable_type, :document_typeable_type
    rename_column :document_types, :documentable_id, :document_typeable_id
  end
end
