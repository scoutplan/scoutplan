# frozen_string_literal: true

class DistributionList
  attr_accessor :key, :name, :description, :keywords

  def initialize(key: nil, name: nil, keywords: nil, description: nil)
    @key = key
    @name = name
    @keywords = keywords
    @description = description
  end

  def emailable?
    true
  end

  def contactable?
    true
  end

  def smsable?
    true
  end
end
