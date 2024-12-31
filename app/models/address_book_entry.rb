# frozen_string_literal: true

class AddressBookEntry
  attr_reader :name, :key, :description, :keywords

  def contactable_status
    "contactable"
  end
end
