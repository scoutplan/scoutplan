# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)
  end

  require "icalendar"

  describe "ical" do
    it "works" do
      Time.zone = @unit.settings(:locale).time_zone
      starts_at = 36.hours.from_now
      ends_at = 38.hours.from_now
      event = FactoryBot.create( \
        :event,
        :published,
        unit: @unit,
        location: Faker::Address.community,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at: starts_at,
        ends_at: ends_at \
      )
      magic_link = MagicLink.generate_link(@normal_member, "icalendar")
      visit(calendar_feed_unit_events_path(@unit, magic_link.token))

      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      cal_event = cal.events.first
      expect(cal_event.dtstart.utc).to be_within(1.second).of(starts_at)
      expect(cal_event.summary).to eq(event.title)
      expect(cal_event.location).to eq(event.location)
      expect(cal_event.description).to eq(event.description.to_plain_text)
      expect(cal_event.url.to_s).not_to be_empty
    end

    it "excludes cancelled and draft events for admins" do
      @unit.events.destroy_all
      FactoryBot.create( \
        :event,
        :published,
        unit: @unit,
        location: Faker::Address.community,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at: 36.hours.from_now,
        ends_at: 38.hours.from_now \
      )
      FactoryBot.create( \
        :event,
        :cancelled,
        unit: @unit,
        location: Faker::Address.community,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at: 40.hours.from_now,
        ends_at: 42.hours.from_now \
      )
      FactoryBot.create( \
        :event,
        :draft,
        unit: @unit,
        location: Faker::Address.community,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at: 50.hours.from_now,
        ends_at: 52.hours.from_now \
      )
      expect(@unit.events.count).to eq(3)
      magic_link = MagicLink.generate_link(@admin_member, "icalendar")
      visit(calendar_feed_unit_events_path(@unit, magic_link.token))
      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      expect(cal.events.count).to eq(1)
    end
  end
end
# rubocop:enable Metrics/BlockLength
