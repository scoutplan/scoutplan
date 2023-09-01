# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event::Icalendarable, type: :model do
  before do
    @event = FactoryBot.create(:event)
  end

  describe "methods" do
    it "returns the correct filename" do
      expected = "#{@event.unit.name} #{@event.title} on #{@event.starts_at.strftime('%b %-d %Y')}" \
                 "#{Event::Icalendarable::FILE_EXTENSION_ICAL}"
      expect(@event.ical_filename).to eq(expected)
    end
  end
end
