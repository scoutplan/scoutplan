# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe EventRsvpPolicy, type: :model do
  before do
    @member = FactoryBot.create(:unit_membership, :youth)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @unit)
  end

  describe "create?" do
    describe "ordinary schmoe" do
      it "cannot RSVP for others" do
        other_member = FactoryBot.create(:unit_membership, unit: @unit)
        rsvp = EventRsvp.new(unit_membership: other_member, event: @event)
        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?).to be_falsey
      end
    end

    describe "event organizers" do
      it "can RSVP for the event" do
        other_member = FactoryBot.create(:unit_membership, unit: @unit)
        @event.organizers.create(unit_membership: @member)
        rsvp = EventRsvp.new(unit_membership: other_member, event: @event)
        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?).to be_truthy
      end
    end

    describe "child rsvps" do
      it "can RSVP for their children" do
        child = FactoryBot.create(:unit_membership, :youth)
        @member.child_relationships.create(child_unit_membership: child)
        rsvp = EventRsvp.new(unit_membership: child, event: @event)
        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(child)).to be_truthy
      end

      it "cannot RSVP for other children" do
        child = FactoryBot.create(:unit_membership, :youth)
        rsvp = EventRsvp.new(unit_membership: child, event: @event)
        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(child)).to be_falsey
      end
    end

    describe "youth rsvps" do
      it "prevents youth rsvps by default" do
        rsvp = EventRsvp.new(unit_membership: @member, event: @event)
        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(@member)).to be_falsey
      end

      it "allows youth rsvps if the unit, membership, and event allows them" do
        @member.allow_youth_rsvps = true
        @unit.allow_youth_rsvps = true
        @event.allow_youth_rsvps = true

        rsvp = EventRsvp.new(unit_membership: @member, event: @event)

        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(@member)).to be_truthy
      end

      it "prevents youth rsvps if the unit prevents it" do
        @member.allow_youth_rsvps = true
        @event.allow_youth_rsvps = true
        @unit.update(allow_youth_rsvps: false)

        rsvp = EventRsvp.new(unit_membership: @member, event: @event)

        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(@member)).to be_falsey
      end

      it "prevents rsvps if the membership prevents it" do
        @unit.allow_youth_rsvps = true
        @event.allow_youth_rsvps = true

        rsvp = EventRsvp.new(unit_membership: @member, event: @event)

        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(@member)).to be_falsey
      end

      it "prevents rsvps if the event prevents it" do
        @member.allow_youth_rsvps = true
        @unit.allow_youth_rsvps = true
        @event.allow_youth_rsvps = false

        rsvp = EventRsvp.new(unit_membership: @member, event: @event)

        policy = EventRsvpPolicy.new(@member, rsvp)
        expect(policy.create?(@member)).to be_falsey
      end      
    end
  end
end
# rubocop:enable Metrics/BlockLength
