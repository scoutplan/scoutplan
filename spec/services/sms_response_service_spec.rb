# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmsResponseService, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @child1 = FactoryBot.create(:member, unit: @unit)
    @child2 = FactoryBot.create(:member, unit: @unit)
    @spouse = FactoryBot.create(:member, unit: @unit, status: "registered")
    MemberRelationship.create!(parent_member: @member, child_member: @child1)
    MemberRelationship.create!(parent_member: @member, child_member: @child2)
    MemberRelationship.create!(parent_member: @member, child_member: @spouse)

    @event = FactoryBot.create(:event, unit: @member.unit, requires_rsvp: true, starts_at: 1.week.from_now, status: :published)
    @service = RsvpService.new(@member, @event)
  end

  it "is set up correctly" do
    expect(@member.family(include_self: true).count).to eq(4)
    expect(@service.family_fully_responded?).to be_falsey
  end

  it "records responses" do
    params = { "From" => @member.phone, "Body" => "  YES!  " }
    service = SmsResponseService.new(params)
    service.process
    expect(@service.family_fully_responded?).to be_truthy
  end
end
