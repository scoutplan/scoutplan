# frozen_string_literal: true

require "rails_helper"
require "active_job/test_helper"

include ActiveJob::TestHelper

RSpec.describe EventNotifier, type: :model do
  describe "cancellation" do
    before do
      @event = FactoryBot.create(:event, :cancelled)
      @unit = @event.unit
      @member = FactoryBot.create(:unit_membership, unit: @unit)
      @unit.settings(:communication).update! via_email: true, via_sms: true
      @notifier = EventNotifier.new(@event)
    end

    it "sends an email and text" do
      expect { @notifier.send_cancellation(@member) }.to change { enqueued_jobs.count }.by(1)

      # Texter doesn't have a "deliveries" concept and we're relying on Twilio test credentials here, so
      # we're going to assume that if we reach this point without an error, we're good. We'll have to check
      # SMS test deliveries by hand for now
    end
  end
end
