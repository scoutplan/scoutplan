# frozen_string_literal: true

require "rails_helper"

RSpec.describe MemberNotifier, type: :model do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
  end

  it "instantiates" do
    expect { MemberNotifier.new(@member) }.not_to raise_exception
  end

  describe "methods" do
    before do
      @notifier = MemberNotifier.new(@member)
    end

    it "sends a test message" do
      expect { @notifier.send_test_message }.not_to raise_exception
    end

    it "skips reminders when member has declined" do
      Timecop.freeze(DateTime.now.change( { hour: 9, minute: 0 } ))
      event = FactoryBot.create(:event, unit: @unit, starts_at: 12.hours.from_now,
                                        requires_rsvp: true, status: :published)
      event.rsvps.create!(unit_membership: @member, response: :declined, respondent: @member)
      expect { @notifier.send_daily_reminder }.to change { ActionMailer::Base.deliveries.count }.by(0)
      Timecop.return
    end
  end

  describe "weekly digest" do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @member.user.update(phone: "555-555-5555")
      @member.settings(:communication).via_sms = true
      @member.save!
      @event = FactoryBot.create(:event, unit: @unit, status: :published, starts_at: 5.days.from_now)
      @forbidden_event = FactoryBot.create(:event, unit: @unit, status: :published, starts_at: 5.days.from_now,
                                                   title: "Forbidden Donut")
      @forbidden_event.tag_list.add("trendy clique")
      @forbidden_event.save!
    end

    it "skips ineligible events" do
      expect { MemberNotifier.new(@member).send_digest }.to change { ActionMailer::Base.deliveries.count }.by(1)
      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).to include(@event.title)
      expect(body).not_to include(@forbidden_event.title)
    end

    it "shows eligible events" do
      @member.tag_list.add("trendy clique")
      @member.save!
      
      expect { MemberNotifier.new(@member).send_digest }.to change { ActionMailer::Base.deliveries.count }.by(1)
      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).to include(@event.title)
      expect(body).to include(@forbidden_event.title)
    end
  end

  describe "event organizer digest" do
    before do
      @event = FactoryBot.create(:event, :requires_rsvp, unit: @unit, status: "published", starts_at: 12.hours.from_now)
      @event.event_organizers.create!(unit_membership: @member)
      accepting_member = FactoryBot.create(:member, unit: @unit)
      declining_member = FactoryBot.create(:member, unit: @unit)
      @event.rsvps.create!(unit_membership: accepting_member, response: :accepted, respondent: @member, created_at: 1.day.ago)
      @event.rsvps.create!(unit_membership: declining_member, response: :declined, respondent: @member)
    end

    it "is set up correctly" do
      @event.reload
      expect(@event.requires_rsvp).to be_truthy
      expect(@event.organizers.count).to eq(1)
      expect(@event.organizers.map(&:unit_membership)).to include(@member)
      expect(@member.organized_events).to include(@event)
      expect(@event.rsvps.count).to eq(2)
    end

    it "sends a digest" do
      notifier = MemberNotifier.new(@member)
      expect { notifier.send_event_organizer_digest }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "skips inactive members" do
      FactoryBot.create(:unit_membership, unit: @unit, status: :inactive)
      notifier = MemberNotifier.new(@member)
      expect { notifier.send_event_organizer_digest }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
