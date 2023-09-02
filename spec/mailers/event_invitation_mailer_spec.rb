# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventInvitationMailer, type: :mailer do
  before do
    @event = FactoryBot.create(:event, starts_at: 21.days.from_now, ends_at: 22.days.from_now)
    @member = FactoryBot.create(:member, unit: @event.unit)
  end

  describe "event invitation persisted" do
    it "creates a new EventInvitation record" do
      expect do
        EventInvitationMailer.with(event_id: @event.id, member: @member).event_invitation_email.deliver
      end.to change { EventInvitation.count }.by(1)
    end

    it "doesn't create a duplicate EventInvitation record" do
      EventInvitation.create(event: @event, member: @member)
      expect do
        EventInvitationMailer.with(event_id: @event.id, member: @member).event_invitation_email.deliver
      end.to change { EventInvitation.count }.by(0)
    end
  end

  describe "mail content" do
    it "includes an ical part" do
      mail = EventInvitationMailer.with(event_id: @event.id, member: @member).event_invitation_email
      expect(mail.multipart?).to be_truthy
      expect(mail.body.parts.count).to eq(2)

      calendar_content_type = "text/calendar; charset=UTF-8; component=VEVENT; method=REQUEST"
      expect(mail.body.parts.map(&:content_type)).to include(calendar_content_type)
    end
  end
end
