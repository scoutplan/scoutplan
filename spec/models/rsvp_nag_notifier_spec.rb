# frozen_string_literal: true

require "rails_helper"

RSpec.describe RsvpNagNotifier, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "instantiates" do
    expect { RsvpNagNotifier.new(@member) }.not_to raise_exception
  end

  it "sends a message" do
    notifier = RsvpNagNotifier.new(@member)
    expect { notifier.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
