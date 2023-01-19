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
      @message = @unit.messages.create!(author: @adult, recipients: "event_#{@event.id}_attendees", body: "test")
      @service = MessageService.new(@message)
    end

    it "is set up correctly" do
      expect(@event.rsvps.count).to eq(1)
    end

    it "has an event cohort" do
      expect(@message.event_cohort?).to be_truthy
    end

    it "includes parents" do
      expect(@service.resolve_members.count).to eq(2)
      expect(@service.resolve_members).to include(@adult)
    end
  end
end
