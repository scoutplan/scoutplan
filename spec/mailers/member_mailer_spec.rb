require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe MemberMailer, type: :mailer do
  describe "digest email" do
    before do
      @member = FactoryBot.create(:member)

      @unit = @member.unit
      Time.zone = "UTC"
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit,
                                 starts_at: 4.days.from_now.utc.change(hour: 0, min: 15),
                                 ends_at: 5.days.from_now.utc.change(hour: 0, min: 15),
                                 rsvp_closes_at: 3.days.from_now)

      @this_week_events = @unit.events.published.this_week
      @upcoming_events = @unit.events.published.coming_up

      @mail = MemberMailer.with(member: @member,
                                this_week_events: @this_week_events,
                                upcoming_events: @upcoming_events).digest_email
    end

    it "renders the headers" do
      expect(@mail.subject).to eq("[#{@unit.name}] Weekly Digest")
    end

    it "correctly renders the body" do
      Time.zone = "UTC"
      expect(@mail.body).to include(@unit.name)
      # expect(@mail.body).to include(@member.display_first_name)
      expect(@mail.body).to include(@event.title)
      # expect(@mail.body).to include(@event.starts_at.in_time_zone(@unit.time_zone).strftime("%A, %b %-d"))
      # expect(@mail.body).to include(@event.starts_at.in_time_zone(@unit.time_zone).strftime("%-I:%M %p"))
    end

    describe "RSVP statuses" do
      before do
        @family_member1 = FactoryBot.create(:member, unit: @unit)
        @family_member2 = FactoryBot.create(:member, unit: @unit)
        @family_member1.parent_relationships.create(parent_member: @member)
        @family_member2.parent_relationships.create(parent_member: @member)
      end

      it "renders the correct status for an event with no family RSVPs" do
        expect(@mail.body).to include("RSVP Needed")
      end

      it "renders the correct status for an event with some family RSVPs" do
        @event.rsvps.create(member: @family_member1, response: :accepted, respondent: @member)
        expect(@mail.body).to include("Complete your RSVP")
      end

      it "renders the correct status for an event with all family RSVPs" do
        @member.family.each do |member|
          @event.rsvps.create(member: member, response: :accepted, respondent: @member)
        end
        expect(@mail.body).to include("Change RSVP")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
