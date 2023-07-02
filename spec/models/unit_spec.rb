# frozen_string_literal: true

require "rails_helper"

RSpec.describe Unit, type: :model do
  it "has a valid base factory" do
    expect(FactoryBot.build(:unit)).to be_valid
  end

  it "has a valid factory with members" do
    expect(FactoryBot.build(:unit_with_members)).to be_valid
  end

  context "callbacks" do
    it "creates default categories" do
      EventCategory.create(name: "Troop Meeting")
      EventCategory.create(name: "Camping")
      EventCategory.create(name: "Court of Honor")

      @category_count = EventCategory.seeds.count

      unit = Unit.create!(name: "Troop 1234", location: "North Kilttown")

      # unit = FactoryBot.create(:unit)
      expect(unit.event_categories.count).to eq(@category_count)
    end
  end

  context "validations" do
    it "requires a name" do
      expect(FactoryBot.build(:unit, name: nil)).not_to be_valid
    end
  end

  context "methods" do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @user = @member.user
    end

    it "finds a membership for a user" do
      expect(@unit.membership_for(@user)).to eq(@member)
    end

    it "renders a short name correctly" do
      @unit.name = "Troop 123"
      expect(@unit.short_name).to eq("T123")
    end
  end

  describe "creation" do
    it "creates unique slugs" do
      unit = FactoryBot.create(:unit, name: "Troop 1234")
      second_unit = FactoryBot.create(:unit, name: "Troop 1234")
      expect(unit.slug).to eq("troop-1234")
      expect(unit.slug).to start_with("troop-1234-")
    end
  end
end
