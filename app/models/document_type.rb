# frozen_string_literal: true

# represents an abstract document (e.g. "BSA Health Form")
class DocumentType < ApplicationRecord
  belongs_to :documentable, polymorphic: true
end
