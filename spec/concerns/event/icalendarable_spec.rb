# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Icalendarable, type: :model do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @member = FactoryBot.create(:member, unit: @unit)
  end

  describe "methods" do
    it "returns the correct filename" do
      expected = "#{@event.unit.name} #{@event.title} on #{@event.starts_at.strftime('%b %-d %Y')}" \
                 "#{Event::Icalendarable::FILE_EXTENSION_ICAL}"
      expect(@event.ical_filename).to eq(expected)
    end

    describe "to_ical_event" do
      it "returns an Icalendar::Event" do
        expect(@event.to_ical_event).to be_a(Icalendar::Event)
      end

      it "publishes the event without ATTENDEE properties so clients don't render RSVP buttons" do
        expect(@event.to_ical_event.attendee).to be_empty
      end

      it "renders all-day events correctly" do
        @event.update!(all_day: true)
        ical_event = @event.to_ical_event

        expected_start = @event.starts_at.in_time_zone(@unit.time_zone).beginning_of_day.to_date
        expected_end   = @event.ends_at.in_time_zone(@unit.time_zone).advance(days: 1).end_of_day.to_date

        expect(ical_event.dtstart).to eq(expected_start)
        expect(ical_event.dtend).to eq(expected_end)
      end
    end
  end
end
