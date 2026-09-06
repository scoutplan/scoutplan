# frozen_string_literal: true

require "rails_helper"

describe Event::DatePresentable do
  let(:unit) { FactoryBot.create(:unit) }

  def event_at(starts, ends, all_day: false)
    FactoryBot.create(:event, unit: unit, starts_at: starts, ends_at: ends, all_day: all_day)
  end

  describe "#times_to_s" do
    it "is nil for an all-day event" do
      event = event_at(Time.zone.parse("2026-09-08 00:00"), Time.zone.parse("2026-09-08 23:59"), all_day: true)

      expect(event.times_to_s).to be_nil
    end

    it "drops :00 on the hour" do
      event = event_at(Time.zone.parse("2026-09-08 19:00"), Time.zone.parse("2026-09-08 20:00"))

      expect(event.times_to_s(plain_text: true)).to eq("7 PM—8 PM")
    end

    it "keeps minutes when there are any" do
      event = event_at(Time.zone.parse("2026-09-08 18:30"), Time.zone.parse("2026-09-08 20:15"))

      expect(event.times_to_s(plain_text: true)).to eq("6:30 PM—8:15 PM")
    end

    it "collapses to a single label when start and end read the same" do
      moment = Time.zone.parse("2026-09-08 19:00")
      event = event_at(moment, moment)

      expect(event.times_to_s(plain_text: true)).to eq("7 PM")
    end

    it "spans a multi-day event" do
      event = event_at(Time.zone.parse("2026-09-11 18:00"), Time.zone.parse("2026-09-13 11:00"))

      expect(event.times_to_s(plain_text: true)).to eq("6 PM—11 AM")
    end
  end
end
