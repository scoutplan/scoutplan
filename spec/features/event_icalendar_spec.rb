# frozen_string_literal: true

require "rails_helper"
require "icalendar"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active, member_type: :adult, ical_suppress_declined: true)
  end

  describe "ical" do
    it "responds with a valid iCal feed" do
      starts_at = 36.hours.from_now
      ends_at = 38.hours.from_now
      event = FactoryBot.create(:event,
                                :published,
                                unit:        @unit,
                                starts_at:   starts_at,
                                ends_at:     ends_at,
                                description: Faker::Lorem.paragraph(sentence_count: 3))
      visit(calendar_feed_unit_events_path(@unit, @normal_member.token))

      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      cal_event = cal.events.first

      Time.zone = @unit.time_zone

      expect(cal_event.dtstart).to be_within(1.second).of event.starts_at.to_datetime

      expect(cal_event.summary.to_s).to eq("#{@unit.short_name} - #{event.title}")
      expect(cal_event.location).to eq(event.full_address)
      expect(cal_event.description).to eq(event.description.to_plain_text)
      expect(cal_event.url.to_s).not_to be_empty
    end

    it "returns a 404 if the token is invalid" do
      visit(calendar_feed_unit_events_path(@unit, "invalid-token"))
      expect(page.status_code).to eq(404)
    end

    it "excludes events where the entire family has declined" do
      new_event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
      visit(calendar_feed_unit_events_path(@unit, @normal_member.token))
      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      cal_event = cal.events.first
      expect(cal.events.count).to eq(1)
      new_event.rsvps.create!(unit_membership: @normal_member, response: :declined, respondent: @normal_member)
      visit(calendar_feed_unit_events_path(@unit, @normal_member.token))
      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      cal_event = cal.events.first
      expect(cal.events.count).to eq(0)
    end

    it "includes cancelled and draft events for admins" do
      @unit.events.destroy_all
      FactoryBot.create( \
        :event,
        :published,
        unit:        @unit,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at:   36.hours.from_now,
        ends_at:     38.hours.from_now \
      )
      FactoryBot.create( \
        :event,
        :cancelled,
        unit:        @unit,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at:   40.hours.from_now,
        ends_at:     42.hours.from_now \
      )
      FactoryBot.create( \
        :event,
        :draft,
        unit:        @unit,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at:   50.hours.from_now,
        ends_at:     52.hours.from_now \
      )
      expect(@unit.events.count).to eq(3)
      visit(calendar_feed_unit_events_path(@unit, @admin_member.token))
      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      expect(cal.events.count).to eq(3)
    end
  end
end
# rubocop:enable Metrics/BlockLength
