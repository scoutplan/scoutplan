require "rails_helper"

RSpec.describe FamilyRsvp, type: :model do
  it "instantiates with a unit_membership and event" do
    unit_membership = FactoryBot.create(:unit_membership)
    event = FactoryBot.create(:event)
    expect(FamilyRsvp.new(unit_membership, event)).to be_a FamilyRsvp
  end

  describe "payment methods" do
    before do
      @youth_member = FactoryBot.create(:unit_membership, :youth)
      @unit = @youth_member.unit
      @unit.update(allow_youth_rsvps: true)
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @parent.child_relationships.create(child_unit_membership: @youth_member)
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit, cost_adult: 10, cost_youth: 5)
      @youth_rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @parent, response: "accepted_pending")
      @adult_rsvp = @event.rsvps.create!(unit_membership: @parent, respondent: @parent, response: "accepted_pending")
    end

    it "calculates the cost" do
      rsvp = FamilyRsvp.new(@youth_member, @event)
      expect(rsvp.balance_due).to eq(15)

      rsvp = FamilyRsvp.new(@youth_member, @event)
      @adult_rsvp.update(response: "declined")
      expect(rsvp.balance_due).to eq(5)
    end

    it "calculates the amount paid" do
      @event.payments.create(unit_membership: @youth_member, amount: 100, method: "cash", received_by: @parent)
      rsvp = FamilyRsvp.new(@youth_member, @event)
      expect(rsvp.amount_paid).to eq(1)
      expect(rsvp.balance_due).to eq(14)
      # expect(rsvp.paid_in_full?).to be_falsey
      expect(rsvp.paid?).to eq(:partial)

      @event.payments.create(unit_membership: @youth_member, amount: 1400, method: "cash", received_by: @parent)
      expect(rsvp.amount_paid).to eq(15)
      expect(rsvp.balance_due).to eq(0)
      # expect(rsvp.paid_in_full?).to be_truthy
      expect(rsvp.paid?).to eq(:in_full)
    end
  end
end
