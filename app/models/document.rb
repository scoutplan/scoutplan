class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :document_type, optional: true
  has_one_attached :file

  acts_as_taggable_on :document_tags
  acts_as_taggable_tenant :unit_id
end
