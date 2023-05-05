# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "payments", type: :feature do
  before do
    @unit = FactoryBot.create(:unit_with_members)
    @member = FactoryBot.create(:member, :admin, unit: @unit)
    @child1 = FactoryBot.create(:member, :youth, unit: @unit)
    @child2 = FactoryBot.create(:member, :youth, unit: @unit)
    @member.child_relationships.create(child_unit_membership: @child1)
    @member.child_relationships.create(child_unit_membership: @child2)
    @event = FactoryBot.create(:event, unit: @unit, cost_youth: 500, cost_adult: 300)
    @event.rsvps.create(unit_membership: @member, response: :accepted, respondent: @member)
    @event.rsvps.create(unit_membership: @child1, response: :accepted, respondent: @member)
    @event.rsvps.create(unit_membership: @child2, response: :accepted, respondent: @member)
    login_as(@member.user, scope: :user)
  end

  describe "received payments" do
    it "records a payment" do
      visit receive_unit_event_payments_path(@unit, @event, member: @member.id)
      expect(page).to have_content("$1,300.00")
      expect(page).to have_content("Receive Payment")
      fill_in("payment_amount", with: 1300)
      expect { click_button "Receive Payment" }.to change { Payment.count }.by(1)
      expect(page).to have_current_path(unit_event_payments_path(@unit, @event))
      expect(Payment.last.amount).to eq(130000)
    end

    it "rejects bad input" do
      visit receive_unit_event_payments_path(@unit, @event, member: @member.id)
      fill_in("payment_amount", with: -1300)
      click_button "Receive Payment"
    end
  end
end