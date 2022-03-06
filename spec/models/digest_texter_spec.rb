# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe DigestTexter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @troop_meeting = FactoryBot.create(
      :event,
      unit: @member.unit,
      starts_at: 3.days.from_now,
      status: :published
    )

    # the committee meeting will be at 7:15 PM Eastern, 00:15 UDT,
    # so we can test timezone conversion

    Time.zone = "UTC"

    @committee_meeting = FactoryBot.create(
      :event,
      unit: @member.unit,
      starts_at: 4.days.from_now.change(hour: 0, min: 15),
      status: :published,
      title: "Committee Meeting"
    )
  end

  describe "body" do
    # Hi, Scouty. Here's what's going on at Troop 231:
    it "contains the member greeting" do
      texter = DigestTexter.new @member
      member_greeting = "Hi, #{@member.display_first_name}. Coming up at #{@member.unit.name}:"
      expect(texter.body).to include member_greeting
    end

    # Make sure URLs are correctly formed: https://local.scoutplan.org
    it "contains the host" do
      texter = DigestTexter.new @member
      base_url = ENV["SCOUTPLAN_HOST"]
      expect(texter.body).to include base_url
    end

    it "ends with a period" do
      texter = DigestTexter.new @member
      expect(texter.body.last).to eq(".")
    end

    # * Hiking Trip on Friday
    it "contains event synopsis" do
      texter = DigestTexter.new @member
      event_synopsis = "* #{@committee_meeting.title} on #{@committee_meeting.starts_at.in_time_zone(@unit.time_zone).strftime('%A')}"
      expect(texter.body).to include event_synopsis
    end
  end
end
# rubocop:enable Metrics/BlockLength
