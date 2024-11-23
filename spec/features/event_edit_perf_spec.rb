require "rails_helper"

RSpec.describe Event, type: :feature do
  describe "performance" do
    it "is fast" do
      event = FactoryBot.create(:event)
      unit = event.unit
      100.times do
        FactoryBot.create(:unit_membership, unit: unit)
      end

      now = Time.now
      5.times do
        visit edit_unit_event_path(unit, event)
      end
      puts "That took #{(Time.now - now) * 1000} milliseconds"
    end
  end
end
