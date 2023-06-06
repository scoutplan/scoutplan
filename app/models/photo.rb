class Photo < ApplicationRecord
  belongs_to :unit
  belongs_to :event, optional: true
  belongs_to :author, class_name: "UnitMembership", foreign_key: "author_id"
  acts_as_taggable_on :tags
  has_many_attached :images
end
