# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventCancellationService, type: :model do
  before do
    @event = FactoryBot.create(:event, :published)
  end

  it "cancels" do
    service = EventCancellationService.new(@event, event: { message_audience: "none" })
    service.cancel
    @event.reload
    expect(@event.cancelled?).to be_truthy
  end
end
