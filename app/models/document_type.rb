# frozen_string_literal: true

# represents an abstract document (e.g. "BSA Health Form")
class DocumentType < ApplicationRecord
  scope :required, -> { where(required: true) }
  belongs_to :document_typeable, polymorphic: true
end
