class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :document_type, optional: true
  has_one_attached :file

  acts_as_taggable_on :document_tags
  acts_as_taggable_tenant :documentable_id

  scope :by_date, -> { order(document_date: :desc) }

  before_commit :set_document_date, on: :create

  def document_tag=(tag_attrs)
    tag_name = tag_attrs[:name]
    if tag_attrs[:_destroy] == "true"
      document_tag_list.remove(tag_name)
    else
      document_tag_list.add(tag_name)
    end
    save!
  end

  private

  def set_document_date
    self.document_date = created_at unless document_date.present?
  end
end
