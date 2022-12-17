# frozen_string_literal: true

require "rails_helper"

# Texter class for reminding members to RSVP to upcoming events
RSpec.describe EventOrganizerDigestTexter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @member.unit,
                                                                   starts_at: 2.weeks.from_now)
    @event.rsvps.create(member: @member, response: "accepted", respondent: @member)
  end

  describe "body" do
    # Hi, Scouty. Here's what's going on at Troop 231:
    it "contains the member greeting" do
      rsvps = @event.rsvps.group_by(&:response)
      new_rsvps = @event.rsvps
      last_ran_at = 1.week.ago
      texter = EventOrganizerDigestTexter.new(@member, @event, rsvps, new_rsvps, last_ran_at)
      expected_body = "Hi, #{@member.display_first_name}"
      expect(texter.body).to include(expected_body)
    end
  end
end
