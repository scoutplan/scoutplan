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

      unit = Unit.create!(name: "Troop 1234", location: "North Kilttown", slug: "troop1234northkilttown")

      # unit = FactoryBot.create(:unit)
      expect(unit.event_categories.count).to eq(@category_count)
    end
  end

  it "generates a valid slug" do
    unit = Unit.new(name: "Troop 1234", location: "North Kilttown")
    unit.save!
    unit.reload
    expect(unit.slug).to be_present
  end

  context "validations" do
    it "requires a name" do
      expect(FactoryBot.build(:unit, name: nil)).not_to be_valid
    end

    it "requires a unique slug" do
      unit = FactoryBot.create(:unit)
      dupe = FactoryBot.build(:unit, slug: unit.slug)
      expect(dupe).not_to be_valid
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

  describe "unit_memberships#with_guardians" do
    before do
      @unit = FactoryBot.create(:unit)
      @event = FactoryBot.create(:event, unit: @unit)
      @youth = FactoryBot.create(:unit_membership, :youth, unit: @unit)
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @youth.parent_relationships.create!(parent_unit_membership: @parent)
      @event.event_rsvps.create!(unit_membership: @youth, respondent: @parent, response: "accepted")
      # MemberRelationship.create!(parent_unit_membership: @parent, child_unit_membership: @youth)
    end

    it "returns parents of youth members" do
      # expect(@event.recipients).to include(@parent)
      expect(@youth.contactable?).to be_falsey
      expect(@parent.contactable?).to be_truthy
      expect(@event.unit_memberships).to include(@youth)
      expect(@event.recipients).not_to include(@youth)
      expect(@event.recipients).to include(@parent)

      # expect(@unit.unit_memberships.with_guardians).to include(@parent)
      # expect(@unit.unit_memberships.with_guardians).not_to include(@youth)
    end
  end
end
