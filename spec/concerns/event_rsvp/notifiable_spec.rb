require "rails_helper"

RSpec.describe EventRsvp::Notifiable, type: :concern do
  before do
    @event = FactoryBot.create(:event, :published, :requires_rsvp)
    @unit = @event.unit
    @member = FactoryBot.create(:member, :adult, unit: @unit)
    @organizer = FactoryBot.create(:member, :adult, unit: @unit)
    @event.event_organizers.create!(unit_membership: @organizer, assigned_by: @organizer)
  end

  describe "#notification_recipients" do
    describe "event has RSVP requirement" do
      it "only includes accepted members" do
        rsvp = FactoryBot.create(:event_rsvp, :accepted, event: @event, member: @member, respondent: @member)
        expect(rsvp.notification_recipients).to include(@member)
      end

      it "excludes non-accepted members" do
        rsvp = FactoryBot.create(:event_rsvp, :pending, event: @event, member: @member, respondent: @member)
        expect(rsvp.notification_recipients).not_to include(@member)
      end
    end

    describe "tagged event" do
      it "includes only members with matching tags" do
        @event.tags.create!(name: "Soccer")
        tagged_member = FactoryBot.create(:member, :adult, unit: @unit)
        tagged_member.tag_list.add("Soccer")
        tagged_member.save!
        rsvp = FactoryBot.create(:event_rsvp, :accepted, event: @event, member: tagged_member,
respondent: tagged_member)

        expect(rsvp.notification_recipients).to include(tagged_member)
      end

      it "excludes members without matching tags" do
        @event.tags.create!(name: "Soccer")
        untagged_member = FactoryBot.create(:member, :adult, unit: @unit)
        rsvp = FactoryBot.create(:event_rsvp, :accepted, event: @event, member: untagged_member,
respondent: untagged_member)

        expect(rsvp.notification_recipients).not_to include(untagged_member)
      end
    end
  end

  describe "callbacks" do
    it "enqueues an email job" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)

      expect { rsvp.save! }.to have_enqueued_job(Noticed::EventJob)
    end

    it "enqueues an SMS job" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)
      expect { rsvp.save! }.to have_enqueued_job(Noticed::EventJob)
    end

    it "enqueues an organizer notification job" do
      rsvp = FactoryBot.build(:event_rsvp, event: @event, member: @member, respondent: @member)
      expect { rsvp.save! }.to have_enqueued_job(Noticed::EventJob)
    end
  end
end
