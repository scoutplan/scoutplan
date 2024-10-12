class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :document_type, optional: true
  has_one_attached :file

  acts_as_taggable_on :document_tags
  acts_as_taggable_tenant :documentable_id

  scope :by_date, -> { order(document_date: :desc) }

  before_commit :set_document_date, on: :create

  private

  def set_document_date
    self.document_date = created_at
  end
end
