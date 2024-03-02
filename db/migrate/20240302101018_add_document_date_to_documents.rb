class AddDocumentDateToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :document_date, :datetime

    Document.all.each do |document|
      document.update!(document_date: document.created_at)
    end
  end
end
