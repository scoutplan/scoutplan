# frozen_string_literal: true

# an article to be published in the next digest
class NewsItem < ApplicationRecord
  acts_as_list
  belongs_to :unit
  ALL_STATES = %w[draft ready_to_send sent].freeze
  enum status: ALL_STATES.zip(ALL_STATES).to_h
end
