# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpLastCallNotifier do
  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @member.user.update(phone: "+13395788645")
  end

  it "creates a notifier" do
    expect(RsvpLastCallNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    expect { RsvpLastCallNotifier.with(event: @event).deliver([@member]) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
