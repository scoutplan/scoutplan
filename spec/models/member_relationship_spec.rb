require "rails_helper"

RSpec.describe MemberRelationship, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:member_relationship)).to be_valid
  end

  describe "validations" do
    it "prevents duplicates" do
      example = FactoryBot.create(:member_relationship)
      dupe = FactoryBot.build(:member_relationship,
                              parent_member: example.parent_member,
                              child_member:  example.parent_member)
      expect(dupe).not_to be_valid
    end

    it "prevents self reference" do
      member = FactoryBot.create(:member)
      example = FactoryBot.build(:member_relationship, parent_member: member, child_member: member)
      expect(example).not_to be_valid
    end

    it "requires a parent" do
      expect(FactoryBot.build(:member_relationship, parent_member: nil)).not_to be_valid
    end

    it "requires a child" do
      expect(FactoryBot.build(:member_relationship, child_member: nil)).not_to be_valid
    end
  end

  describe "relationships" do
    before do
      @parent_member = FactoryBot.create(:parent_member)
      @child_member  = FactoryBot.create(:child_member, unit: @parent_member.unit)
      @parent_member.child_relationships.create!(child_member: @child_member)
    end

    it "establishes child relationship" do
      expect(@parent_member.children).to include(@child_member)
    end

    it "establishes parent relationship" do
      expect(@child_member.parents).to include(@parent_member)
    end
  end
end
