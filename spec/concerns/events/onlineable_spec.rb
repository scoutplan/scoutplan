# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Onlineable, type: :concern do
  before do
    @event = FactoryBot.create(:event)
  end

  describe "methods" do
    describe "hostname" do
      it "returns the correct hostname" do
        @event.website = "https://us02web.zoom.us/j/1234567890?pwd=snuh"
        expect(@event.hostname).to eq("us02web.zoom.us")
      end
    end

    describe "joinable" do
      it "returns true when event starts in 15 minutes" do
        @event.starts_at = 14.minutes.from_now
        expect(@event.joinable?).to be_truthy
      end

      it "returns false when event starts more than 15 minutes in the future" do
        @event.starts_at = 16.minutes.from_now
        expect(@event.joinable?).to be_falsey
      end

      it "returns false when event is over" do
        @event.starts_at = 24.hours.ago
        @event.ends_at = 23.hours.ago
        expect(@event.joinable?).to be_falsey
      end
    end
  end

  describe "validations" do
    describe "website" do
      it "is valid when blank" do
        @event.website = ""
        expect(@event).to be_valid
      end

      it "is valid when a valid URL" do
        @event.website = "https://go.scoutplan.org/1234"
        expect(@event).to be_valid
      end

      it "is invalid when an invalid URL" do
        @event.website = "Wampeters, Foma and Granfalloons"
        expect(@event).not_to be_valid
      end
    end
  end
end
