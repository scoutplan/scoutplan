# frozen_string_literal: true

# A class to notify members about various events. A Notifier
# wraps both email and text (and any other future communication modes).
#
# The Notifier is responsible for honoring Unit, Member, and User communication
# preferences and policies.

# A Notifier class for sending messages to existing members (e.g. event reminders, etc.)
class MemberNotifier < ApplicationNotifier
  def initialize(member)
    @member = member
    super()
  end

  def contactable
    @member
  end

  def send_test_message
    send_email { |recipient| MemberMailer.with(member: recipient).test_email.deliver_later }
    send_text  { |recipient| TestTexter.new(recipient).send_message }
  end

  def send_digest
    return unless Flipper.enabled?(:digest, @member)

    send_email { |recipient| MemberMailer.with(member: recipient).digest_email.deliver_later }
    send_text  { |recipient| DigestTexter.new(recipient).send_message }
  end

  def send_daily_reminder
    return unless daily_reminder?

    send_email { |recipient| MemberMailer.with(member: recipient).daily_reminder_email.deliver_later }
    send_text  { |recipient| DailyReminderTexter.new(recipient).send_message }
  end

  def send_family_rsvp_confirmation(event)
    send_email do |recipient|
      MemberMailer.with(member: recipient, event_id: event.id)
                  .family_rsvp_confirmation_email.deliver_later
    end
    send_text { |recipient| FamilyRsvpConfirmationTexter.new(recipient, event).send_message }
  end

  def send_message(message, preview: false)
    send_email { |recipient| MemberMailer.with(member: recipient, message_id: message.id, preview: preview).message_email.deliver_later }
  end

  # pass an option array of UnitMembership ids for bulk reponses
  def send_rsvp_confirmation(event)
    rsvp = EventRsvp.find_by(event: event, unit_membership: @member)
    # send_email { |recipient| MemberMailer.with(member: recipient, event_id: event.id, member_ids: member_ids).rsvp_confirmation_email.deliver_later }
    send_text  { |recipient| RsvpConfirmationTexter.new(recipient, event, rsvp).send_message }
  end

  def send_rsvp_nag
    notifier = RsvpNagNotifier.new(@member)
    notifier.perform    
  end

  private

  # should member receive daily reminders?
  def daily_reminder?
    events = @member.unit.events.published.imminent

    # strip out events that the family has explicitly declined
    service = RsvpService.new(@member)
    events = events.reject do |event|
      service.event = event
      event.requires_rsvp && service.family_fully_declined?
    end
    events.count.positive?
  end
end
