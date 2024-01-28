require "rails_helper"

RSpec.describe RsvpNagNotifier do
  before do
    @event = FactoryBot.create(:event)
    @member = FactoryBot.create(:unit_membership, :adult, unit: @event.unit)
    @member.user.update(phone: "+13395788645")
    @unit = @event.unit
    @unit.settings(:communication).update(digest: "true")
    Flipper.enable(:rsvp_nag, @member)
  end

  it "creates a notifier" do
    expect(RsvpNagNotifier.new).to be_a(ScoutplanNotifier)
  end

  it "delivers an email" do
    Flipper.enable(:deliver_email)
    expect { RsvpNagNotifier.with(event: @event).deliver([@member]) }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "doesn't deliver an email if the feature is disabled" do
    Flipper.disable(:deliver_email)
    expect { RsvpNagNotifier.with(event: @event).deliver([@member]) }
      .not_to(change { ActionMailer::Base.deliveries.count })
  end
end
