require "rails_helper"

RSpec.describe WeeklyDigestMailer, type: :mailer do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp,
                               rsvp_closes_at: 12.hours.from_now,
                               starts_at:      36.hours.from_now,
                               ends_at:        60.hour.from_now,
                               cost_adult:     20.00,
                               cost_youth:     20.00)
    @unit = @event.unit
    @member = FactoryBot.create(:member, unit: @unit)
  end

  describe "RSVP prompt" do
    it "prompts for unresponded events" do
      mail = WeeklyDigestMailer.with(recipient: @member, unit: @unit).weekly_digest_notification
      expect(mail.body.encoded).to have_content("Your RSVP is needed")
    end

    it "doesn't prompt when events are fully responded" do
      @event.rsvps.create!(unit_membership: @member, response: "accepted", respondent: @member)
      mail = WeeklyDigestMailer.with(recipient: @member, unit: @unit).weekly_digest_notification
      expect(mail.body.encoded).not_to have_content("Your RSVP is needed")
    end
  end

  describe "payment prompt" do
    before do
      @event.rsvps.create!(unit_membership: @member, response: "accepted", respondent: @member)
    end

    it "prompts for unpaid events" do
      mail = WeeklyDigestMailer.with(recipient: @member, unit: @unit).weekly_digest_notification
      expect(mail.body.encoded).to have_content(I18n.t("events.partials.event_row.payment_outstanding"))
    end

    it "doesn't prompt for paid events" do
      @event.payments.create!(unit_membership: @member, amount: 2000)
      mail = WeeklyDigestMailer.with(recipient: @member, unit: @unit).weekly_digest_notification
      expect(mail.body.encoded).to have_content(I18n.t("events.partials.event_row.fully_paid"))
    end
  end
end
