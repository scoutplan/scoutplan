# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def digest_email
    member = Unit.first.members.first
    news_items = member.unit.news_items.queued
    member.unit.events.where(title: "Preview Test Event").destroy_all
    event = member.unit.events.new(
      title: "Preview Test Event",
      starts_at: 24.hours.from_now,
      ends_at: 25.hours.from_now,
      status: :published,
      location: "Meeting place",
      event_category: member.unit.event_categories.first
    )
    event.save!
    MemberMailer.with(member: member, news_items: news_items).digest_email
  end

  def daily_reminder_email
    member = Unit.first.members.first
    member.unit.events.where(title: "Preview Test Event").destroy_all
    event = member.unit.events.new(
      title: "Preview Test Event",
      starts_at: 3.hours.from_now,
      ends_at: 4.hours.from_now,
      status: :published,
      location: "Meeting place",
      event_category: member.unit.event_categories.first
    )
    event.save!
    MemberMailer.with(member: member).daily_reminder_email
  end

  def test_email
    member = Unit.first.members.first
    MemberMailer.with(member: member).test_email
  end
end
