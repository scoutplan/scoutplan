# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessageNotification do
  before do
    @event = FactoryBot.create(:event)
    @member = FactoryBot.create(:unit_membership, unit: @event.unit)
    @member.user.update(phone: "+13395788645")
    @unit = @event.unit
    @unit.settings(:communication).daily_reminder = "true"
    @message = FactoryBot.create(:message, unit: @unit, author: @member, body: "<div>asd</div>")
  end

  it "creates a notifier" do
    expect(MessageNotification.new).to be_a(ScoutplanNotification)
  end

  it "delivers an email" do
    expect { MessageNotification.with(message: @message).deliver([@member]) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
