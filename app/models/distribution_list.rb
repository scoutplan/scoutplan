# frozen_string_literal: true

class DistributionList
  attr_accessor :key, :name, :description

  def initialize(key: nil, name: nil, description: nil)
    @key = key
    @name = name
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
