class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :document_type

  validates_uniqueness_of :documentable_id, scope: [:documentable_type, :document_type]
end
