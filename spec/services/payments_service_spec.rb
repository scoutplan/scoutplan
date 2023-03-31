# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsService, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, unit: @unit, cost_adult: 20)
    @rsvp = @event.rsvps.create!(unit_membership: @member, response: "accepted", respondent: @member)
  end

  describe "#paid?" do
    before do
      @service = PaymentsService.new(@event, @member)
    end

    it "expects family to owe $20" do
      expect(@service.family_amount_total).to eq(20)
    end

    it "returns false if no payment is made" do
      expect(@service.paid?).to eq(:none)
    end

    it "returns true if a payment is made" do
      FactoryBot.create(:payment, event: @event, unit_membership: @member, amount: 2000)
      expect(@service.paid?).to eq(:in_full)
    end

    it "returns partial" do
      FactoryBot.create(:payment, event: @event, unit_membership: @member, amount: 2000)
      family_member = FactoryBot.create(:member, unit: @unit)
      family_member.parent_relationships.create(parent_member: @member)
      @event.rsvps.create!(unit_membership: family_member, response: "accepted", respondent: @member)
      expect(@service.paid?).to eq(:partial)
    end
  end
end
