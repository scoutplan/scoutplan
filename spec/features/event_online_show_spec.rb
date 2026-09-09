# frozen_string_literal: true

require "rails_helper"

describe "an online event's show page", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, unit: @unit)
    @event.event_locations.destroy_all
    login_as(@member.user, scope: :user)
  end

  describe "with a meeting URL" do
    before do
      @event.update!(online: true, online_url: "https://us02web.zoom.us/j/1234567890")
      visit unit_event_path(@unit, @event)
    end

    it "links to the meeting" do
      expect(page).to have_link(href: "https://us02web.zoom.us/j/1234567890")
    end

    it "labels the link with the host rather than the raw URL" do
      expect(page).to have_link("us02web.zoom.us")
    end

    it "opens it in a new tab safely" do
      link = find("a[href='https://us02web.zoom.us/j/1234567890']")

      expect(link[:target]).to eq("_blank")
      expect(link[:rel]).to include("noopener")
    end
  end

  describe "flagged online but without a URL yet" do
    before do
      @event.update!(online: true, online_url: nil)
      visit unit_event_path(@unit, @event)
    end

    it "still shows the section, with a placeholder" do
      expect(page).to have_css("#locations")
      expect(page).to have_content("Meeting link to come")
    end

    it "is not a link, since there is nothing to open" do
      expect(page).to have_no_link("Online meeting")
    end
  end

  describe "an in-person event" do
    it "shows places instead, and no online block" do
      place = FactoryBot.create(:location, unit: @unit, name: "Parish Hall")
      FactoryBot.create(:event_location, event: @event, location: place, location_type: "arrival")

      visit unit_event_path(@unit, @event)

      expect(page).to have_content("Parish Hall")
      expect(page).to have_no_content("Join online meeting")
      expect(page).to have_no_content("Meeting link to come")
    end
  end

  describe "an event with neither" do
    it "omits the locations section entirely" do
      visit unit_event_path(@unit, @event)

      expect(page).to have_no_css("#locations")
    end
  end

  describe "Event#hostname" do
    it "returns nil rather than raising on a URL the old website column allowed" do
      event = FactoryBot.build(:event, online: true, online_url: "not a url")

      expect { event.hostname }.not_to raise_error
    end
  end
end
