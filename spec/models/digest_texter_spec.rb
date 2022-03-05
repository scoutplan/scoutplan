# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe DigestTexter, type: :model do
  before do
    @member = FactoryBot.create(:member)
    FactoryBot.create(:event, unit: @member.unit, starts_at: 3.days.from_now, status: :published)
    FactoryBot.create(
      :event,
      unit: @member.unit,
      starts_at: 4.days.from_now,
      status: :published,
      title: "Committee Meeting"
    )
  end

  it "instantiates" do
    expect { DigestTexter.new @member }.not_to raise_exception
  end

  it "renders" do
    texter = DigestTexter.new @member
    # just dump the text to the screen so we can see it
    puts
    puts "**************************************"
    puts
    puts texter.body
    puts
    puts "**************************************"
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
      base_url = "#{ENV['SCOUTPLAN_HOST']}"
      expect(texter.body).to include base_url
    end

    it "ends with a period" do
      texter = DigestTexter.new @member
      expect(texter.body.last).to eq(".")
    end

    # * Hiking Trip on Friday
    it "contains event synopsis" do
      texter = DigestTexter.new @member
      event = @member.unit.events.first
      event_synopsis = "* #{event.title} on #{event.starts_at.strftime('%A')}"
      expect(texter.body).to include event_synopsis
    end
  end
end
# rubocop:enable Metrics/BlockLength
