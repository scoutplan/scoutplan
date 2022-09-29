# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationPolicy, type: :model do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
    @non_admin = FactoryBot.create(:member, unit: @unit)
    @event = FactoryBot.create(:event, unit: @unit)
    @location = Location.new
    EventLocation.create(event: @event, location: @location)
  end

  it "permits edit by an admin" do
    ap @location
    expect(LocationPolicy.new(@admin, @location).edit?).to be_truthy
  end

  it "denies edit by a non-admin" do
    expect(LocationPolicy.new(@non_admin, @location).edit?).to be_falsey
  end
end
