# frozen_string_literal: true

require "rails_helper"

RSpec.describe FamilyPresenter, type: :model do
  before do
    @member = FactoryBot.create(:member)
  end

  describe "active member names" do
    it "returns 'you' if only one active member" do
      presenter = FamilyPresenter.new(@member)
      expect(presenter.active_member_names_list).to eq("you")
    end

    it "returns 'you and X' if two active members" do
      child1 = FactoryBot.create(:member, unit: @member.unit)
      MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: child1)
      @member.reload
      presenter = FamilyPresenter.new(@member)
      expect(presenter.active_member_names_list).to eq("you and #{child1.display_first_name}")
    end

    # expected: "you, Lenna, and Lorina"
    # got: "you, Lorina, and Lenna"
    it "returns 'you, X, and Y' if three active members" do
      child1 = FactoryBot.create(:member, unit: @member.unit)
      child2 = FactoryBot.create(:member, unit: @member.unit)
      MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: child1)
      MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: child2)
      @member.reload
      presenter = FamilyPresenter.new(@member)
      expect(presenter.active_member_names_list).to eq("you, #{child1.display_first_name}, and #{child2.display_first_name}") || eq("you, #{child2.display_first_name}, and #{child1.display_first_name}")
    end
  end
end
