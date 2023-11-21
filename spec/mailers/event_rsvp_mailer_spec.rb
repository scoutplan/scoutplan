require "rails_helper"

RSpec.describe EventRsvpMailer, type: :mailer do
  before do
    @youth_member = FactoryBot.create(:unit_membership, :youth)
    @unit = @youth_member.unit
    @unit.update(allow_youth_rsvps: true)
    @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @parent.child_relationships.create(child_unit_membership: @youth_member)
    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    @rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @parent, response: "accepted")

    @mail = EventRsvpMailer.with(event_rsvp: @rsvp, recipient: @parent).event_rsvp_notification
  end

  it "renders the headers" do
    expect(@mail.subject).to eq("[#{@unit.name}] Your RSVP for #{@event.title} has been received")
  end
end
