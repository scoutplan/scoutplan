# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Icalendarable, type: :model do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @member = FactoryBot.create(:member, unit: @event.unit)
  end

  describe "methods" do
    it "returns the correct filename" do
      expected = "#{@event.unit.name} #{@event.title} on #{@event.starts_at.strftime('%b %-d %Y')}" \
                 "#{Event::Icalendarable::FILE_EXTENSION_ICAL}"
      expect(@event.ical_filename).to eq(expected)
    end

    describe "to_ical_event" do
      it "returns an Icalendar::Event" do
        expect(@event.to_ical_event(@member)).to be_a(Icalendar::Event)
      end

      it "includes ATTENDEE property if RSVP is open" do
        ical_event = @event.to_ical_event(@member)
        expect(ical_event.attendee.count).to eq(1)
      end

      it "doesn't include ATTENDEE property if RSVP is closed" do
        @event.update!(requires_rsvp: false)
        ical_event = @event.to_ical_event(@member)
        expect(ical_event.attendee.count).to eq(0)
      end
    end
  end
end
