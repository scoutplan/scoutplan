# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def digest_email
    member = Unit.first.members.first
    news_items = member.unit.news_items.queued
    member.unit.events.where(title: "Preview Test Event").destroy_all
    event = member.unit.events.new(
      title: "Preview Test Event",
      short_description: "I can't believe it's not butter",
      starts_at: 24.hours.from_now,
      ends_at: 25.hours.from_now,
      status: :published,
      event_category: member.unit.event_categories.first
    )
    event.save!
    MemberMailer.with(member: member, news_items: news_items).digest_email
  end

  def digest_email_without_upcoming_events
    member = Unit.first.members.first
    member.unit.events.where(title: "Preview Test Event").destroy_all
    MemberMailer.with(member: member, news_items: nil).digest_email
  end

  def daily_reminder_email
    member = Unit.first.members.first
    member.unit.events.where(title: "Preview Test Event").destroy_all
    event = member.unit.events.new(
      title: "Preview Test Event",
      starts_at: 8.hours.from_now,
      ends_at: 9.hours.from_now,
      status: :published,
      event_category: member.unit.event_categories.first
    )
    event.save!
    MemberMailer.with(member: member).daily_reminder_email
  end

  def event_organizer_daily_digest_email
    unit = Unit.first
    organizer = unit.members.first
    event = unit.events.future.first
    event.rsvps.destroy_all
    event.rsvps.find_or_create_by(unit_membership: organizer, response: "accepted", respondent: organizer)
    event.rsvps.find_or_create_by(unit_membership: unit.members.second, response: "declined", respondent: organizer)
    event.rsvps.find_or_create_by(unit_membership: unit.members.third, response: "declined", respondent: organizer, created_at: 2.days.ago)
    rsvps = event.rsvps.group_by(&:response)

    MemberMailer.with(event: event,
                      member: organizer,
                      rsvps: rsvps,
                      last_ran_at: 24.hours.ago)
                .event_organizer_daily_digest_email
  end

  def test_email
    member = Unit.first.members.first
    MemberMailer.with(member: member).test_email
  end

  def rsvp_nag_email
    member = FactoryBot.create(:member)
    unit = member.unit
    child1 = FactoryBot.create(:member, unit: unit)
    child2 = FactoryBot.create(:member, unit: unit)
    member.child_relationships.create(child_member: child1)
    member.child_relationships.create(child_member: child2)
    unit = member.unit
    event = FactoryBot.create(:event, :requires_rsvp, unit: unit, location: "State Park")
    event.rsvps.create!(member: child2, response: :accepted, respondent: member)
    MemberMailer.with(event_id: event.id, member: member).rsvp_nag_email
  end
end
