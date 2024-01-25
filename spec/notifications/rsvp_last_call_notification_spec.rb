# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpLastCallNotification do
  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @member.user.update(phone: "+13395788645")
  end

  it "creates a notifier" do
    expect(RsvpLastCallNotification.new).to be_a(ScoutplanNotification)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    expect { RsvpLastCallNotification.with(event: @event).deliver([@member]) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
