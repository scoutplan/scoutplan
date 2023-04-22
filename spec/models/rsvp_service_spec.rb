# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpService, type: :model do
  before do
    # set up family
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @child1 = FactoryBot.create(:member, unit: @unit)
    @child2 = FactoryBot.create(:member, unit: @unit)
    @spouse = FactoryBot.create(:member, unit: @unit, status: "registered")
    MemberRelationship.create!(parent_member: @member, child_member: @child1)
    MemberRelationship.create!(parent_member: @member, child_member: @child2)
    MemberRelationship.create!(parent_member: @member, child_member: @spouse)

    @event = FactoryBot.create(:event, unit: @member.unit, requires_rsvp: true, starts_at: 1.week.from_now, status: :published)
    @service = RsvpService.new(@member, @event)
  end

  it "is set up correctly" do
    expect(@member.family(include_self: true).count).to eq(4)
  end

  # rubocop:disable Metrics/BlockLength
  describe "unresponded_events method" do
    describe "active family has all declined" do
      it "returns no events" do
        @event.rsvps.create!(member: @member, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child2, response: :declined, respondent: @member)
        expect(@service.unresponded_events).not_to include(@event)
      end
    end

    describe "active family has all accepted" do
      it "returns no events" do
        @event.rsvps.create!(member: @member, response: :accepted, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :accepted, respondent: @member)
        @event.rsvps.create!(member: @child2, response: :accepted, respondent: @member)
        expect(@service.unresponded_events).not_to include(@event)
      end
    end

    describe "some active family hasn't responded" do
      it "returns the event" do
        @event.rsvps.create!(member: @member, response: :accepted, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :accepted, respondent: @member)
        # @child2 hasn't responded
        expect(@service.unresponded_events).to include(@event)
      end
    end

    describe "no family has responded" do
      it "returns the event" do
        expect(@service.unresponded_events).to include(@event)
      end
    end

    describe "family non-respondents" do
      it "returns family members who haven't responded to the Event" do
        @event.rsvps.create!(member: @member, response: :accepted, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :accepted, respondent: @member)
        result = @service.family_non_respondents
        expect(result.count).to eq(1)
        expect(result.first).to eq(@child2)
      end
    end
  end

  describe "family_fully_declined? method" do
    describe "active family has all declined" do
      it "returns true if registered member hasn't responded" do
        @event.rsvps.create!(member: @member, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child2, response: :declined, respondent: @member)
        expect(@service.family_fully_declined?).to be_truthy
      end

      # this is kinda edge-casey, but all active members could decline while a friend/family
      # member accepts. In this case, the family is considered *not* declined
      it "returns false if registered member has accepted" do
        @event.rsvps.create!(member: @member, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child1, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @child2, response: :declined, respondent: @member)
        @event.rsvps.create!(member: @spouse, response: :accepted, respondent: @member)
        expect(@service.family_fully_declined?).to be_falsey
      end
    end

    it "returns false if active family has only partially responded" do
      @event.rsvps.create!(member: @member, response: :declined, respondent: @member)
      @event.rsvps.create!(member: @child1, response: :declined, respondent: @member)
      # @child2 hasn't responded
      expect(@service.family_fully_declined?).to be_falsey
    end
  end

  describe "record_family_response method" do
    it "creates the correct number of RSVPs" do
      @service.record_family_response(:accepted)
      expect(@event.rsvps.count).to eq(3)
    end
  end

  describe "expiring rsvps" do
    it "returns events that are expiring" do
      @event.update!(starts_at: 14.day.from_now, ends_at: 15.day.from_now, rsvp_closes_at: 1.day.from_now)
      service = RsvpService.new(@member)
      expect(service.expiring_rsvp_events).to include(@event)
    end

    it "exlucdes events that aren't expiring" do
      @event.update!(starts_at: 14.day.from_now, ends_at: 15.day.from_now, rsvp_closes_at: 2.days.from_now)
      service = RsvpService.new(@member)
      expect(service.expiring_rsvp_events).not_to include(@event)
    end    
  end
end
# rubocop:enable Metrics/BlockLength
