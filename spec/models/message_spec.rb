require "rails_helper"
require "active_job/test_helper"

RSpec.describe Message, type: :model do
  include ActiveJob::TestHelper

  before do
    @adult = FactoryBot.create(:member)
    @unit = @adult.unit
    @youth = FactoryBot.create(:member, :youth, unit: @unit)
    @adult.child_relationships.create(child_unit_membership: @youth)
  end

  it "has a valid factory" do
    expect(FactoryBot.build(:message)).to be_valid
  end

  describe "dup" do
    it "dupes recipients" do
      message = FactoryBot.create(:message, unit: @unit)
      @members = []
      5.times do
        @members << FactoryBot.create(:unit_membership)
        message.message_recipients.create!(unit_membership: @members.last)
      end
      expect(message.message_recipients.count).to eq(5)
      expect { message.dup }.to change { MessageRecipient.count }.by(@members.count)
    end
  end

  describe "unit_memberships#with_guardians" do
    skip 
    before do
      @unit = FactoryBot.create(:unit)
      @event = FactoryBot.create(:event, unit: @unit)
      @youth = FactoryBot.create(:unit_membership, :youth, unit: @unit)
      @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
      @youth.parent_relationships.create!(parent_unit_membership: @parent)
      @event.event_rsvps.create!(unit_membership: @youth, respondent: @parent, response: "accepted")
      # MemberRelationship.create!(parent_unit_membership: @parent, child_unit_membership: @youth)
    end

    it "returns parents of youth members" do
      # expect(@event.recipients).to include(@parent)
      expect(@youth.contactable?).to be_falsey
      expect(@parent.contactable?).to be_truthy
      expect(@event.unit_memberships).to include(@youth)
      expect(@event.recipients).not_to include(@youth)
      expect(@event.recipients).to include(@parent)

      # expect(@unit.unit_memberships.with_guardians).to include(@parent)
      # expect(@unit.unit_memberships.with_guardians).not_to include(@youth)
    end
  end
end
