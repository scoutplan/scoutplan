# frozen_string_literal: true

# A class to notify members about various events. A Notifier
# wraps both email and text (and any other future communication modes).
#
# The Notifier is responsible for honoring Unit, Member, and User communication
# preferences and policies.

# A Notifier class for sending messages to existing members (e.g. event reminders, etc.)
class MemberNotifier
  def self.send_test_message(member)
    return unless member.contactable?

    MemberMailer.with(member: member).test_email.deliver_later if member.settings(:communication).via_email
    TestTexter.new(member).send_message
  end

  def self.send_digest(member)
    return unless member.contactable? && Flipper.enabled?(:digest, member)

    MemberMailer.with(member: member).digest_email.deliver_later if member.settings(:communication).via_email
    DigestTexter.new(member).send_message if member.settings(:communication).via_sms
  end

  def self.send_daily_reminder(member)
    return unless daily_reminders?(member)

    MemberMailer.with(member: member).daily_reminder_email.deliver_later if member.settings(:communication).via_email
    DailyReminderTexter.new(member).send_message if member.settings(:communication).via_sms
  end

  def self.daily_reminders?(member)
    member.contactable? &&
      Flipper.enabled?(:receive_daily_reminder, member) &&
      member.unit.events.published.imminent.count.positive?
  end
end
