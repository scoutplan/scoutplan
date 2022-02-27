# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventCancellationService, type: :model do
  require "sidekiq/testing"

  before do
    @event = FactoryBot.create(:event, :published)
  end

  it "cancels" do
    EventCancellationService.new.perform(@event.id, event: { message_audience: "none" })
    @event.reload
    expect(@event.cancelled?).to be_truthy
  end
end
