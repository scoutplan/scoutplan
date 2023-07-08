# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

RSpec.describe EventOrganizer, type: :model do
  it "notifies the organizer when they are assigned" do
    @member = FactoryBot.create(:unit_membership)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @unit)
    expect do
      @organizer = FactoryBot.create(:event_organizer, event: @event, unit_membership: @member, assigned_by: @member)
    end.to change { Notification.count }.by(1)
  end
end
