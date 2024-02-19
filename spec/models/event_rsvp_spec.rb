require "rails_helper"

RSpec.describe EventRsvp, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:event_rsvp)).to be_valid
  end

  describe "validations" do
    before do
      @youth_member = FactoryBot.create(:unit_membership, :youth)
      @unit = @youth_member.unit
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @parent.child_relationships.create(child_unit_membership: @youth_member)
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    end

    it "prevents duplicates" do
      rsvp = FactoryBot.create(:event_rsvp)
      dupe = FactoryBot.build(:event_rsvp, unit_membership_id: rsvp.unit_membership_id, event_id: rsvp.event_id)
      expect(dupe).not_to be_valid
    end

    it "prevents mismatched Unit associations" do
      member = FactoryBot.create(:unit_membership)
      event = FactoryBot.create(:event)

      # member and event should belong to different Units at this point
      expect(member.unit).not_to eq(event.unit)

      rsvp = EventRsvp.new(event: event, member: member, respondent: member, response: :declined)
      expect(rsvp).not_to be_valid
    end
  end

  describe "approval flow" do
    before do
      @youth_member = FactoryBot.create(:unit_membership, :youth)
      @unit = @youth_member.unit
      @unit.update(allow_youth_rsvps: true)
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @parent.child_relationships.create(child_unit_membership: @youth_member)
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    end

    it "prevents unauthorized youth RSVPs" do
      rsvp = @event.rsvps.new(unit_membership: @youth_member, respondent: @youth_member, response: "accepted")
      expect(rsvp).not_to be_valid
    end

    it "prevents youth RSVPs when unit disallows it" do
      @unit.update(allow_youth_rsvps: false)
      @youth_member.update(allow_youth_rsvps: true)
      rsvp = @event.rsvps.new(unit_membership: @youth_member, respondent: @youth_member, response: "accepted")
      expect(rsvp).not_to be_valid
    end

    it "allows authorized youth member to RSVP" do
      @youth_member.update(allow_youth_rsvps: true)
      rsvp = @event.rsvps.new(unit_membership: @youth_member, respondent: @youth_member, response: "accepted")
      expect(rsvp).to be_valid
    end

    it "RSVP changes from pending to finalized when an adult updates" do
      rsvp = @event.rsvps.create(unit_membership: @youth_member, respondent: @youth_member, response: "accepted_pending")
      rsvp.update(respondent: @parent, response: "accepted")
      rsvp.reload
      expect(rsvp.response).to eq("accepted")
    end

    it "RSVP changes to pending when a youth responds" do
      @youth_member.update(allow_youth_rsvps: true)
      rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @youth_member, response: "accepted")
      expect(rsvp.response).to eq("accepted_pending")
    end

    it "RSVP remains pending when a youth updates" do
      @youth_member.update(allow_youth_rsvps: true)
      rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @youth_member, response: "accepted_pending")
      rsvp.update!(respondent: @youth_member, response: "accepted")
      expect(rsvp.response).to eq("accepted_pending")
    end

    it "becomes pending with youth responds" do
      @youth_member.update(allow_youth_rsvps: true)
      rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @parent, response: "accepted")
      rsvp.update!(respondent: @youth_member, response: "declined")
      expect(rsvp.response).to eq("declined_pending")
    end
  end

  describe "payments" do
    before do
      @youth_member = FactoryBot.create(:unit_membership, :youth)
      @unit = @youth_member.unit
      @unit.update(allow_youth_rsvps: true)
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @parent.child_relationships.create(child_unit_membership: @youth_member)
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit, cost_adult: 10, cost_youth: 5)
      @youth_rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @parent, response: "accepted_pending")
      @adult_rsvp = @event.rsvps.create!(unit_membership: @parent, respondent: @parent, response: "accepted")
    end

    it "calculates the cost based on member type" do
      expect(@youth_rsvp.cost).to eq(5)
      expect(@adult_rsvp.cost).to eq(10)
    end

    it "calculates the amount paid" do
      expect(@youth_rsvp.paid?).to eq(:none)
      @event.payments.create(unit_membership: @youth_member, amount: 100, method: "cash", received_by: @parent)
      expect(@youth_rsvp.amount_paid).to eq(1)
      expect(@youth_rsvp.balance_due).to eq(4)
      expect(@youth_rsvp.paid?).to eq(:partial)

      @event.payments.create(unit_membership: @youth_member, amount: 400, method: "cash", received_by: @parent)
      expect(@youth_rsvp.amount_paid).to eq(5)
      expect(@youth_rsvp.balance_due).to eq(0)
      expect(@youth_rsvp.paid?).to eq(:in_full)
    end

    it "ignores declined RSVPs" do
      @adult_rsvp.update(response: "declined")
      expect(@adult_rsvp.cost).to eq(0)
    end
  end
end
