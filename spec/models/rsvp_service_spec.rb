# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpService, type: :model do
  before do
    # set up family
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @child_1 = FactoryBot.create(:member, unit: @unit)
    @child_2 = FactoryBot.create(:member, unit: @unit)
    @spouse = FactoryBot.create(:member, unit: @unit, status: "registered")
    MemberRelationship.create!(parent_member: @member, child_member: @child_1)
    MemberRelationship.create!(parent_member: @member, child_member: @child_2)
    MemberRelationship.create!(parent_member: @member, child_member: @spouse)

    @event = FactoryBot.create(:event, unit: @member.unit, requires_rsvp: true)
    @service = RsvpService.new(@member)
    @service.event = @event
  end

  it "is set up correctly" do
    expect(@member.family(include_self: true).count).to eq(4)
  end

  describe "member_family_declined" do
    describe "active family has all declined" do
      it "returns true if registered member hasn't responded" do
        @event.rsvps.create!(member: @member, response: "declined", respondent: @member)
        @event.rsvps.create!(member: @child_1, response: "declined", respondent: @member)
        @event.rsvps.create!(member: @child_2, response: "declined", respondent: @member)
        expect(@service.member_family_declined?(@event)).to be_truthy
      end

      # this is kinda edge-casey, but all active members could decline while a friend/family
      # member accepts. In this case, the family is considered *not* declined
      it "returns false if registered member has accepted" do
        @event.rsvps.create!(member: @member, response: "declined", respondent: @member)
        @event.rsvps.create!(member: @child_1, response: "declined", respondent: @member)
        @event.rsvps.create!(member: @child_2, response: "declined", respondent: @member)
        @event.rsvps.create!(member: @spouse, response: "accepted", respondent: @member)
        expect(@service.member_family_declined?(@event)).to be_falsey        
      end
    end

    it "returns false if active family has only partially responded" do
      @event.rsvps.create!(member: @member, response: "declined", respondent: @member)
      @event.rsvps.create!(member: @child_1, response: "declined", respondent: @member)
      # @child_2 hasn't responded
      expect(@service.member_family_declined?(@event)).to be_falsey        
    end
  end
end