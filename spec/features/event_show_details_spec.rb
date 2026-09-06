# frozen_string_literal: true

require "rails_helper"

describe "event show details", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    login_as(@member.user, scope: :user)
  end

  def published_event(**attrs)
    FactoryBot.create(:event, :published, unit: @unit, **attrs)
  end

  describe "times" do
    it "shows the time range for a timed event" do
      event = published_event(starts_at: 3.days.from_now.change(hour: 19),
                              ends_at: 3.days.from_now.change(hour: 20, min: 30))

      visit unit_event_path(@unit, event)

      # derive the expectation in the unit's zone rather than hardcoding a
      # label: several jobs assign Time.zone globally, so the ambient zone
      # depends on spec ordering
      Time.use_zone(@unit.time_zone) do
        expect(page).to have_css("header.py-3", text: event.time_to_s(event.starts_at))
        expect(page).to have_css("header.py-3", text: event.time_to_s(event.ends_at))
      end
    end

    it "shows no time range for an all-day event" do
      event = published_event(all_day: true,
                              starts_at: 3.days.from_now.change(hour: 0),
                              ends_at: 3.days.from_now.change(hour: 23))

      visit unit_event_path(@unit, event)

      expect(page).to have_no_css("header.py-3", text: /AM|PM/)
    end
  end

  describe "locations" do
    it "lists each location once" do
      event = published_event
      # the factory attaches its own arrival location; clear it so this event
      # has exactly one, or a duplicate render would be masked by the other
      event.event_locations.destroy_all
      location = FactoryBot.create(:location, unit: @unit, name: "Ward Pound Ridge")
      FactoryBot.create(:event_location, event: event, location: location,
                                         location_type: "arrival")

      visit unit_event_path(@unit, event)

      # count occurrences explicitly: have_content(count:) counts matching
      # nodes, not repetitions of the string, so it does not catch duplication
      expect(page.text.scan("Ward Pound Ridge").size).to eq(1)
    end

    it "renders the phone as a formatted tel: link" do
      event = published_event
      location = FactoryBot.create(:location, unit: @unit, phone: "9148647317")
      FactoryBot.create(:event_location, event: event, location: location,
                                         location_type: "arrival")

      visit unit_event_path(@unit, event)

      expect(page).to have_css("a[href='tel:9148647317']", text: "(914) 864-7317")
      expect(page).to have_no_content("9148647317")
    end
  end
end
