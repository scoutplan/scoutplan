# frozen_string_literal: true

class AddressBookDistributionListEntry < AddressBookEntry
  attr_accessor :name, :keywords, :description

  def initialize(name: nil, key: nil, keywords: nil, description: nil)
    @name = name
    @key = key
    @keywords = keywords
    @description = description
    super()
  end

  def key
    "dl_#{@key}"
  end
end
