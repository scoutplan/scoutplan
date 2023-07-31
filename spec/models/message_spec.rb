require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @adult = FactoryBot.create(:member)
    @unit = @adult.unit
    @youth = FactoryBot.create(:member, :youth, unit: @unit)
    @adult.child_relationships.create(child_member: @youth)
  end

  describe "resolve recipients" do
    it "resolves actives" do
    end

    it "resolves registered" do
    end

    it "limits to adults" do
    end

    it "includes parents" do
    end
  end

  describe "event registered" do
    before do
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
      @event.rsvps.create!(member: @youth, response: :accepted, respondent: @adult)
      @message = @unit.messages.create!(author: @adult, audience: "event_#{@event.id}_attendees", body: "test")
      @service = MessageService.new(@message)
    end

    it "is set up correctly" do
      expect(@event.rsvps.count).to eq(1)
    end

    it "has an event cohort" do
      ap @message
      expect(@message.event_cohort?).to be_truthy
    end

    it "includes parents" do
      skip "TODO: fix this test"
      expect(@service.resolve_members.count).to eq(2)
      expect(@service.resolve_members).to include(@adult)
    end

    it "limits to adults" do
      skip "TODO: fix this test"
      another_adult = FactoryBot.create(:member, unit: @unit)
      @event.rsvps.create!(member: another_adult, response: :accepted, respondent: another_adult)

      # this third adult is a 'parent' of another_adult, but shouldn't be included
      # because they're not attending the event
      third_adult = FactoryBot.create(:member, unit: @unit)
      third_adult.child_relationships.create(child_member: another_adult)

      @message.member_type = :adults_only
      expect(@service.resolve_members.count).to eq(1)
    end
  end
end
