# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventsHelper, type: :helper do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @unit)
    @arrival_location = FactoryBot.create(:location, unit: @unit)
    @event.event_locations.create(location: @arrival_location, location_type: :arrival)
  end

  describe "event_map_url" do
    it "renders a valid URL" do
      expect(helper.event_map_url(@event)).not_to be_nil
    end
  end
end
