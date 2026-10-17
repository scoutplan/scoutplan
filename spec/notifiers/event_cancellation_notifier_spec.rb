require "rails_helper"

RSpec.describe EventCancellationNotifier do
  include ActiveJob::TestHelper

  before do
    @unit = FactoryBot.create(:unit)
    @unit.settings(:locale).update!(time_zone: "America/New_York")
    @member = FactoryBot.create(:unit_membership, unit: @unit)
    @params = {unit: @unit, title: "Graymoor", starts_at: Time.utc(2026, 10, 17, 2, 0), note: "Rained out"}
  end

  it "renders the email from the captured title and date in the unit's time zone" do
    mail = EventMailer.with(@params.merge(recipient: @member)).cancellation_email
    expect(mail.subject).to eq("#{@unit.name} Graymoor Cancelled")
    expect(mail.to).to eq([@member.email])
    expect(mail.text_part.body.decoded).to include("Graymoor on October 16 has been cancelled.")
    expect(mail.text_part.body.decoded).to include("Rained out")
  end

  it "renders the SMS" do
    sms = EventCancellationNotifier.with(@params).sms_body(recipient: @member, **@params.except(:unit))
    expect(sms).to include("Graymoor on October 16 has been cancelled. Rained out")
  end

  it "delivers an email" do
    allow_any_instance_of(UnitMembership).to receive(:contactable_via?).and_return(false)
    allow_any_instance_of(UnitMembership).to receive(:contactable_via?).with(:email).and_return(true)
    Flipper.enable(:deliver_email)
    expect do
      perform_enqueued_jobs { EventCancellationNotifier.with(@params).deliver([@member]) }
    end.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
