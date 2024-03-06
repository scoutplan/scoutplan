# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event_reminder
class EventReminderPreview < ActionMailer::Preview
  # https://stackoverflow.com/a/66861942/6756943

  # rubocop:disable Metrics/AbcSize
  def event_reminder_notification_accepted
    around_email do
      event = Event.create!(
        unit:           Unit.first,
        category:       EventCategory.first,
        title:          "Camping Trip",
        starts_at:      12.hours.from_now,
        ends_at:        2.days.from_now,
        requires_rsvp:  true,
        rsvp_closes_at: 11.hours.from_now,
        status:         "published",
        description:    description
      )
      recipient = UnitMembership.first
      recipient.family.each do |member|
        event.rsvps.create_with(response: "accepted", respondent: recipient).find_or_create_by!(unit_membership: member)
      end
      EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
    end
  end

  def event_reminder_notification_no_description
    around_email do
      event = Event.create!(
        unit:           Unit.first,
        category:       EventCategory.first,
        title:          "Camping Trip",
        starts_at:      12.hours.from_now,
        ends_at:        2.days.from_now,
        requires_rsvp:  true,
        rsvp_closes_at: 11.hours.from_now,
        status:         "published"
      )
      recipient = UnitMembership.first
      recipient.family.each do |member|
        event.rsvps.create_with(response: "accepted", respondent: recipient).find_or_create_by!(unit_membership: member)
      end
      EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
    end
  end

  def event_reminder_notification_declined
    around_email do
      event = Event.create!(
        unit:           Unit.first,
        category:       EventCategory.first,
        title:          "Camping Trip",
        starts_at:      12.hours.from_now,
        ends_at:        2.days.from_now,
        requires_rsvp:  true,
        rsvp_closes_at: 11.hours.from_now,
        status:         "published",
        description:    description
      )
      recipient = UnitMembership.first
      recipient.family.each do |member|
        event.rsvps.create_with(response: "declined", respondent: recipient).find_or_create_by!(unit_membership: member)
      end
      EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
    end
  end

  def event_reminder_notification_no_rsvps
    around_email do
      event = Event.create!(
        unit:           Unit.first,
        category:       EventCategory.first,
        title:          "Camping Trip",
        starts_at:      12.hours.from_now,
        ends_at:        2.days.from_now,
        requires_rsvp:  true,
        rsvp_closes_at: 11.hours.from_now,
        status:         "published",
        description:    description
      )
      recipient = UnitMembership.first
      EventReminderMailer.with(event: event, recipient: recipient).event_reminder_notification
    end
  end

  private

  # rubocop:disable Lint/SuppressedException
  def around_email
    message = nil
    begin
      ActiveRecord::Base.transaction do
        message = yield
        message.to_s
        raise ActiveRecord::Rollback
      end
    rescue ActiveRecord::Rollback
    end
    message
  end
  # rubocop:enable Lint/SuppressedException

  def description
    <<~DESC
      I'm baby asymmetrical forage street art deep v kogi JOMO migas flannel truffaut synth neutral milk hotel
      small batch. Mukbang humblebrag quinoa subway tile hashtag. Trust fund +1 bushwick artisan asymmetrical
      farm-to-table blue bottle semiotics kinfolk. Four loko tonx next level crucifix iceland listicle. Mixtape
      thundercats fanny pack, selfies semiotics jean shorts meditation letterpress poke butcher irony locavore
      cornhole. Readymade squid keffiyeh, wayfarers tacos tousled dreamcatcher pug single-origin coffee man braid.
    DESC
  end
  # rubocop:enable Metrics/AbcSize
end
