require "rails_helper"

RSpec.describe EventSeries, type: :model do
  describe "create" do
    it "creates a series of events with an end date" do
      event = FactoryBot.create(:event)
      expect { EventSeries.create_with(event, repeats_until: 12.weeks.from_now) }.to change { Event.count }.by(10)
      expect Event.last != event
      expect Event.last.title == event.title
      expect Event.last.token != event.token
    end

    it "creates a series of events with repeat count" do
      event = FactoryBot.create(:event)
      expect { EventSeries.create_with(event, repeat_count: 5) }.to change { Event.count }.by(5)
    end

    it "duplicates event locations" do
      event = FactoryBot.create(:event)
      expect(event.event_locations.count).to eq(1)
      expect { EventSeries.create_with(event, repeats_until: 12.weeks.from_now) }.to change {
        EventLocation.count
      }.by(10)
    end
  end
end
