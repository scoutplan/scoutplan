# frozen_string_literal: true

require "rails_helper"
require "active_job/test_helper"

RSpec.describe RsvpNagNotifier, type: :model do
  include ActiveJob::TestHelper

  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "instantiates" do
    expect { RsvpNagNotifier.new(@member) }.not_to raise_exception
  end

  it "sends a message when there's an outstanding RSVP" do
    FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit)
    notifier = RsvpNagNotifier.new(@member)
    expect { notifier.perform }.to change { enqueued_jobs.count }.by(1)
  end

  it "doesn't send a message when there're no outstanding RSVPs" do
    notifier = RsvpNagNotifier.new(@member)
    expect { notifier.perform }.to change { enqueued_jobs.count }.by(0)
  end
end
