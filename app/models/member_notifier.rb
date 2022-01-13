# frozen_string_literal: true

# A class to notify members about various events. A Notifier
# wraps both email and text (and any other future communication modes).
#
# The Notifier is responsible for honoring Unit, Member, and User communication
# preferences and policies.

# A Notifier class for sending messages to existing members (e.g. event reminders, etc.)
# the send_email and send_text methods allow us to pass in blocks, and then are responsible
# for honoring business logic and member preferences in a centralized way
class MemberNotifier
  def initialize(member)
    @member = member
  end

  def send_test_message
    return unless @member.contactable?

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

  private

  # should member receive daily reminders?
  def daily_reminder?
    @member.unit.events.published.imminent.count.positive?
  end

  # pipe all email through here to enforce common business rules
  def send_email(&block)
    return unless @member.contactable?
    return unless @member.settings(:communication).via_email

    block.call @member
  end

  # pipe all SMS through here to enforce common business rules
  def send_text(&block)
    return unless @member.contactable?
    return unless @member.settings(:communication).via_sms

    block.call @member
  end
end
