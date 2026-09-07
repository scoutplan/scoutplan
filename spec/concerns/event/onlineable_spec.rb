# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Onlineable, type: :concern do
  before do
    @event = FactoryBot.create(:event)
  end

  describe "methods" do
    describe "hostname" do
      it "returns the correct hostname" do
        @event.online_url = "https://us02web.zoom.us/j/1234567890?pwd=snuh"
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

  # online? reads the flag, not the URL, so an organiser can commit to an online
  # event before they have the link
  describe "online?" do
    it "is false by default" do
      expect(@event.online?).to be(false)
    end

    it "is true once flagged, even with no URL yet" do
      @event.online = true

      expect(@event.online?).to be(true)
      expect(@event.online_link?).to be(false)
    end

    it "is not driven by a URL on its own" do
      @event.online_url = "https://zoom.us/j/1234"

      expect(@event.online?).to be(false)
    end

    # the website column used to stand in for online_url; that fallback is gone
    it "is not driven by the website column" do
      @event.website = "https://example.com/info"

      expect(@event.online?).to be(false)
    end
  end

  describe "online_link?" do
    it "requires both the flag and a URL" do
      @event.online = true
      @event.online_url = "https://zoom.us/j/1234"

      expect(@event.online_link?).to be(true)
    end
  end

  describe "validations" do
    describe "online_url" do
      it "is valid when blank" do
        @event.online_url = ""
        expect(@event).to be_valid
      end

      it "is valid when a valid URL" do
        @event.online_url = "https://go.scoutplan.org/1234"
        expect(@event).to be_valid
      end

      it "is invalid when an invalid URL" do
        @event.online_url = "Wampeters, Foma and Granfalloons"
        expect(@event).not_to be_valid
      end
    end
  end
end
