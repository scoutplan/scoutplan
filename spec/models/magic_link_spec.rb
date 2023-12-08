# frozen_string_literal: true

require "rails_helper"

RSpec.describe MagicLink, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @event = FactoryBot.create(:event, unit: @member.unit)
    @path = "/units/#{@member.unit.to_param}/events/#{@event.to_param}"
  end

  it "instantiates" do
    expect {
      MagicLink.create(unit_membership: @member, path: @path)
    }.not_to raise_exception
  end

  it "generates a MagicLink" do
    expect(MagicLink.generate_link(@member, @path)).to be_a MagicLink
  end
end
