# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmsResponseService, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @child1 = FactoryBot.create(:member, unit: @unit)
    @child2 = FactoryBot.create(:member, unit: @unit)
    @spouse = FactoryBot.create(:member, unit: @unit, status: "registered")
    MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: @child1)
    MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: @child2)
    MemberRelationship.create!(parent_unit_membership: @member, child_unit_membership: @spouse)

    @event = FactoryBot.create(:event, unit: @member.unit, requires_rsvp: true, starts_at: 1.week.from_now, status: :published)
    @service = RsvpService.new(@member, @event)

    values = { "type" => "event", "event_id" => @event.id, "members" => @member.family.select { |m| m.status_active? }.map(&:id) }
    ConversationContext.create(identifier: @member.phone, values: values.to_json)
  end

  it "is set up correctly" do
    expect(@member.family(include_self: true).count).to eq(4)
    expect(@member.family.select(&:status_active?).count).to eq(3)
    expect(@service.family_fully_responded?).to be_falsey
  end

  it "sets up context correctly" do
    ConversationContext.destroy_all
    params = { "From" => @member.phone, "Body" => "next" }
    sms_service = SmsResponseService.new(params, {})
    expect { sms_service.process }.to change { ConversationContext.count }.by(1)
    context = ConversationContext.last
    values = JSON.parse(context.values)
    expect(values["members"].count).to eq(3)
  end

  it "records responses" do
    params = { "From" => @member.phone, "Body" => "  YES!  " }
    service = SmsResponseService.new(params, {})
    expect { service.process }.to change { EventRsvp.count }.by(3)
    expect(@service.family_fully_responded?).to be_truthy
  end
end
