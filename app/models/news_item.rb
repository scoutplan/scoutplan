# frozen_string_literal: true

# an article to be published in the next digest
class NewsItem < ApplicationRecord
  acts_as_list
  belongs_to :unit
  ALL_STATES = %w[draft queued sent].freeze
  enum status: ALL_STATES.zip(ALL_STATES).to_h

  has_rich_text :body

  def promotable?
    draft?
  end

  def demotable?
    queued?
  end

  def editable?
    !sent?
  end

  def deletable?
    !sent?
  end

  def self.mark_all_queued_as_sent_by(unit: nil)
    return unless unit
    unit.news_items.queued.update(status: :sent)
  end
end
