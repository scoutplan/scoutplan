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
    @unit = member.unit
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
    return unless Flipper.enabled?(:digest, @member) || ENV["RAILS_ENV"] == "test"

    find_events

    send_email do |recipient|
      MemberMailer.with(member:           recipient,
                        this_week_events: @this_week_events,
                        upcoming_events:  @upcoming_events).digest_email.deliver_later
    end

    send_text { |recipient| DigestTexter.new(recipient, @this_week_events).send_message }
  end

  def send_family_rsvp_confirmation(event)
    send_email do |recipient|
      MemberMailer.with(member: recipient, event_id: event.id)
                  .family_rsvp_confirmation_email.deliver_later
    end
    send_text { |recipient| FamilyRsvpConfirmationTexter.new(recipient, event).send_message }
  end

  def send_message(message, preview: false)
    send_email do |recipient|
      MemberMailer.with(member: recipient, message_id: message.id, preview: preview).message_email.deliver_later
    end
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

  def find_events
    policy = EventPolicy.new(@member, nil)
    @this_week_events = @unit.events.published.this_week.select { |event| policy.show? event }
    @upcoming_events = @unit.events.published.coming_up.select { |event| policy.show? event }
  end
end
