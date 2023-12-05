require "rails_helper"

RSpec.describe EventRsvpMailer, type: :mailer do
  before do
    @youth_member = FactoryBot.create(:unit_membership, :youth_with_rsvps)
    @unit = @youth_member.unit
    @unit.update(allow_youth_rsvps: true)
    @parent = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @parent.child_relationships.create(child_unit_membership: @youth_member)
    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
    @parent_rsvp = @event.rsvps.create!(unit_membership: @parent, respondent: @parent, response: "accepted")
    @youth_rsvp = @event.rsvps.create!(unit_membership: @youth_member, respondent: @youth_member, response: "accepted")
  end

  describe "mail headers" do
    it "renders the correct subject line when recipient is respondent" do
      subject = "[#{@unit.name}] Your RSVP for #{@event.title} has been received"
      mail = EventRsvpMailer.with(event_rsvp: @parent_rsvp, recipient: @parent).event_rsvp_notification
      expect(mail.subject).to eq(subject)
    end

    describe "requires approval" do
      it "renders the correct subject line when recipient is youth member" do
        subject = "[#{@unit.name}] Action required: approve #{@youth_member.first_name}'s RSVP to the #{@event.title}"
        mail = EventRsvpMailer.with(event_rsvp: @youth_rsvp, recipient: @parent).event_rsvp_notification
        expect(mail.subject).to eq(subject)
      end

      it "renders the correct subject line when recipient is parent" do
        subject = "[#{@unit.name}] Your RSVP to the #{@event.title} is pending approval"
        mail = EventRsvpMailer.with(event_rsvp: @youth_rsvp, recipient: @youth_member).event_rsvp_notification
        expect(mail.subject).to eq(subject)
      end
    end
  end
end
