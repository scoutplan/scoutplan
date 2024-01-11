require "rails_helper"

RSpec.describe MemberRelationship, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:member_relationship)).to be_valid
  end

  describe "validations" do
    it "prevents duplicates" do
      example = FactoryBot.create(:member_relationship)
      dupe = FactoryBot.build(:member_relationship,
                              parent_unit_membership: example.parent_unit_membership,
                              child_unit_membership:  example.parent_unit_membership)
      expect(dupe).not_to be_valid
    end

    it "prevents self reference" do
      member = FactoryBot.create(:member)
      example = FactoryBot.build(:member_relationship, parent_unit_membership: member, child_unit_membership: member)
      expect(example).not_to be_valid
    end

    it "requires a parent" do
      expect(FactoryBot.build(:member_relationship, parent_unit_membership: nil)).not_to be_valid
    end

    it "requires a child" do
      expect(FactoryBot.build(:member_relationship, child_unit_membership: nil)).not_to be_valid
    end
  end

  describe "relationships" do
    before do
      @parent_unit_membership = FactoryBot.create(:parent_unit_membership)
      @child_unit_membership  = FactoryBot.create(:child_unit_membership, unit: @parent_unit_membership.unit)
      @parent_unit_membership.child_relationships.create!(child_unit_membership: @child_unit_membership)
    end

    it "establishes child relationship" do
      expect(@parent_unit_membership.children).to include(@child_unit_membership)
    end

    it "establishes parent relationship" do
      expect(@child_unit_membership.parents).to include(@parent_unit_membership)
    end
  end
end
