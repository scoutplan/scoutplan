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

  def send_test_message
    send_email { |recipient| MemberMailer.with(member: recipient).test_email.deliver_later }
    send_text  { |recipient| TestTexter.new(recipient).send_message }
  end

  def send_digest
    puts @member.id
    return unless Flipper.enabled?(:digest, @member)

    send_email { |recipient| MemberMailer.with(member: recipient).digest_email.deliver_later }
    send_text  { |recipient| DigestTexter.new(recipient).send_message }
  end

  def send_daily_reminder
    return unless daily_reminder?

    send_email { |recipient| MemberMailer.with(member: recipient).daily_reminder_email.deliver_later }
    send_text  { |recipient| DailyReminderTexter.new(recipient).send_message }
  end

  def send_message(message)
    send_email { |recipient| MemberMailer.with(member: recipient, message_id: message.id).message_email.deliver_later }
  end

  private

  # should member receive daily reminders?
  def daily_reminder?
    @member.unit.events.published.imminent.count.positive?
  end
end
