class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :document_type, optional: true
  has_one_attached :file

  acts_as_taggable_on :document_tags
  acts_as_taggable_tenant :documentable_id

  scope :by_date, -> { order(document_date: :desc) }

  before_commit :set_document_date, on: :create

  # called from DocumentSet to add and remove single tags, kind of
  # in the vein of nested attributes
  def document_tag=(tag_attrs)
    tag_name = tag_attrs[:name]
    if tag_attrs[:_destroy] == "true"
      document_tag_list.remove(tag_name)
    else
      document_tag_list.add(tag_name)
    end
    save!
  end
end
