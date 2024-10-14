class WikiPage < ApplicationRecord
  VISIBILITIES = %w[anyone members_only draft].freeze

  belongs_to :unit

  acts_as_taggable_on :wiki_page_tags

  has_paper_trail versions: {
    scope: -> { order("id desc") }
  }

  enum :visibility, VISIBILITIES.zip(VISIBILITIES).to_h

  validates_presence_of :title, :body, :unit_id, :visibility
end
