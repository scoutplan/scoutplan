# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventRsvpPolicy, type: :model do
  before do
    @member = FactoryBot.create(:member, :adult)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
    @event_rsvp = EventRsvp.new(event: @event, unit_membership: @member)
  end

  describe ":create?" do
    it "allows an adult to respond for themselves" do
      expect(EventRsvpPolicy.new(@member, @event_rsvp).create?).to be_truthy
    end
  end
end
