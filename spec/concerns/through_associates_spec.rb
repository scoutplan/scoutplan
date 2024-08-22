require "rails_helper"

RSpec.describe ThroughAssociations, type: :concern do
  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member1 = FactoryBot.create(:member, unit: @unit)
    @member2 = FactoryBot.create(:member, unit: @unit)
  end

  it "works" do
    @event.event_organizers_unit_membership = [@member1.id, @member2.id]
    @event.save!
    @event.reload

    @event.event_organizers.find_or_create_by(unit_membership_id: @member1.id)

    expect(@event.organizers.count).to eq(2)
  end
end
