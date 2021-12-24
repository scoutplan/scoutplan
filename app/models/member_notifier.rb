# frozen_string_literal: true

# notify members about various events
class MemberNotifier
  TWILIO_SID_KEY = 'TWILIO_SID'
  TWILIO_NUMBER_KEY = 'TWILIO_NUMBER'

  # invite a user to a unit through a UnitMembership (aka member)
  def self.invite_member_to_unit(member)
    @magic_link_token = member.magic_link.token if
      @unit.settings(:security).enable_magic_links &&
      @user.settings(:security).enable_magic_links
    MemberMailer.with(member: member).invitation_email.deliver_later
  end

  def self.send_test_message(member)
    return unless member.contactable?

    send_test_sms(member)
  end

  def self.send_digest(member)
    return unless member.contactable?

    Rails.logger.warn { "#{member.short_display_name} is contactable" }
    return unless Flipper.enabled? :digest, member

    Rails.logger.warn { "#{member.short_display_name} is Flipper-enabled" }
    MemberMailer.with(member: member).digest_email.deliver_later if member.settings(:communication).via_email
    send_digest_sms(member) if member.settings(:communication).via_sms
  end

  def self.send_daily_reminder(member)
    return unless member.contactable?

    Rails.logger.warn { 'Member is contactable' }
    return unless Flipper.enabled? :receive_daily_reminder, member

    Rails.logger.warn { 'Flipper enabled ' }
    return unless member.unit.events.published.imminent.count.positive?

    Rails.logger.warn { 'There are imminent events to send' }
    @magic_link_token = member.magic_link.token if
      member.unit.settings(:security).enable_magic_links &&
      member.user.settings(:security).enable_magic_links

    MemberMailer.with(member: member).daily_reminder_email.deliver_later if member.settings(:communication).via_email
    send_daily_reminder_sms(member) if member.settings(:communication).via_sms
  end

  def self.send_sms(member, body)
    to    = member.user.phone
    from  = ENV['TWILIO_NUMBER']
    sid   = Rails.application.credentials.twilio[:account_sid]
    token = Rails.application.credentials.twilio[:auth_token]

    Rails.logger.warn { "Sending SMS to #{to} Twilio SID: #{sid}  token: #{token&.first(3)}...#{token&.last(3)}" }

    client = Twilio::REST::Client.new(sid, token)
    client.messages.create(from: from, to: to, body: body)
  rescue Twilio::REST::RestError => e
    Rails.logger.error { e.message }
  end

  def self.send_test_sms(member)
    body = 'This is a test message from Scoutplan. Log in at https://go.scoutplan.org.'
    send_sms(member, body)
  end

  def self.send_digest_sms(member)
    @magic_link_token = member.magic_link.token if
      member.unit.settings(:security).enable_magic_links &&
      member.user.settings(:security).enable_magic_links

    events = member.unit.events.published.this_week
    body = "Hi, #{member.display_first_name}. Here's what's going on this week at #{member.unit.name}:\n"
    events.each do |event|
      body += "\n* #{event.title} on #{event.starts_at.strftime('%A')}"
    end

    body += "\n\nSee the full calendar at https://go.scoutplan.org/units/#{member.unit.id}/events"
    body += "?r=#{@magic_link_token}" if @magic_link_token
    body += '.'
    send_sms member, body
  end

  # TODO: move this to a Textris texter
  def self.send_daily_reminder_sms(member)
    body = daily_reminder_body member
    send_sms member, body
  end

  def self.daily_reminder_body(member)
    events = member.unit.events.published.imminent
    if member.unit.settings(:security).enable_magic_links && member.user.settings(:security).enable_magic_links
      magic_link_token = member&.magic_link&.token
    end
    date_format = '%I:%M %p'
    message = "Hi, #{member.display_first_name}. Today at #{member.unit.name}:\n\n"
    events.each do |event|
      message += "* #{event.title} at #{event.starts_at.strftime(date_format)}\n"
    end
    message += "\nSee the full calendar at https://go.scoutplan.org/units/#{member.unit.id}/events"
    message += '.'
    message += "?r=#{magic_link_token}" if magic_link_token

    message
  end
end
