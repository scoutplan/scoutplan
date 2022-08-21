# frozen_string_literal: true

require "rails_helper"

# Texter class for reminding members to RSVP to upcoming events
RSpec.describe RsvpNagTexter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @member.unit,
                                                                   starts_at: 2.weeks.from_now)
  end

  describe "body" do
    # Hi, Scouty. Here's what's going on at Troop 231:
    it "contains the member greeting" do
      texter = RsvpNagTexter.new(@member, @event)
      expected_body = "Hi, #{@member.display_first_name}, #{@member.unit.name} here. We need your RSVP for the upcoming Hiking Trip event."
      expect(texter.body).to include(expected_body)
    end
  end
end
