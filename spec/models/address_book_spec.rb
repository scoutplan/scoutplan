require "rails_helper"

RSpec.describe AddressBook, type: :model do
  it "works" do
    unit = FactoryBot.create(:unit)
    10.times.each do
      FactoryBot.create(:unit_membership, unit: unit)
    end
    address_book = AddressBook.new(unit)
    ap address_book.entries
    expect(address_book.entries).to be_a(Array)
    expect(address_book.entries.count).to eq(unit.unit_memberships.count + 3)
  end
end
