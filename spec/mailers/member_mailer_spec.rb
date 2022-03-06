# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe MemberMailer, type: :mailer do
  describe "digest email" do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      Time.zone = "UTC"
      @event = FactoryBot.create(
        :event, :published,
        unit: @unit,
        starts_at: 4.days.from_now.utc.change(hour: 0, min: 15)
      )
      @mail = MemberMailer.with(member: @member).digest_email
    end

    it "renders the headers" do
      expect(@mail.subject).to eq("#{@unit.name} Digest")
    end

    it "correctly renders the body" do
      # ap @mail.body
      Time.zone = "UTC"
      expect(@mail.body).to include(@unit.name)
      expect(@mail.body).to include(@member.display_first_name)
      expect(@mail.body).to include(@event.title)
      expect(@mail.body).to include(@event.starts_at.in_time_zone(@unit.time_zone).strftime("%A, %b %-d"))
      expect(@mail.body).to include(@event.starts_at.in_time_zone(@unit.time_zone).strftime("%-I:%M %p"))
    end
  end

  describe "daily reminder email" do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @mail = MemberMailer.with(member: @member).daily_reminder_email
    end

    it "renders the headers" do
      expect(@mail.subject).to eq("#{@unit.name} — Event Reminder")
    end
  end
end
# rubocop:enable Metrics/BlockLength
