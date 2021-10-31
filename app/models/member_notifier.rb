# frozen_string_literal: true

# notify members about various events
class MemberNotifier
  # invite a user to a unit through a UnitMembership (aka member)
  def self.invite_member_to_unit(member)
    @magic_link_token = member.magic_link.token if
      @unit.settings(:security).enable_magic_links &&
      @user.settings(:security).enable_magic_links
    MemberMailer.with(member: member).invitation_email.deliver_later
  end

  def self.send_digest(member)
    return unless member.contactable?
    return unless Flipper.enabled? :receive_digest, member

    MemberMailer.with(member: member).digest_email.deliver_later if member.settings(:communication).via_email
    # MemberTexter.digest(member: member).deliver_now
    send_digest_sms(member) if member.settings(:communication).via_sms
  end

  def self.send_daily_reminder(member)
    return unless member.contactable?
    return unless Flipper.enabled? :receive_daily_reminder, member
    return unless member.unit.events.published.imminent.count.positive?

    @magic_link_token = member.magic_link.token if
      member.unit.settings(:security).enable_magic_links &&
      member.user.settings(:security).enable_magic_links

    MemberMailer.with(member: member).daily_reminder_email.deliver_later if member.settings(:communication).via_email
    send_daily_reminder_sms(member) if member.settings(:communication).via_sms
  end

  def self.send_digest_sms(member)
    @magic_link_token = member.magic_link.token if
      member.unit.settings(:security).enable_magic_links &&
      member.user.settings(:security).enable_magic_links

    from = ENV['TWILIO_NUMBER']
    to = member.user.phone
    events = member.unit.events.published.this_week
    message = "Hi, #{member.display_first_name}. Here's what's going on this week at #{member.unit.name}:"
    events.each do |event|
      message += "\n* #{event.title} on #{event.starts_at.strftime('%A')}"
    end

    message += "\n\nSee the full calendar at https://go.scoutplan.org/units/#{member.unit.id}/events"
    message += "?r=#{@magic_link_token}" if @magic_link_token
    sid = ENV['TWILIO_SID']
    token = ENV['TWILIO_TOKEN']

    logger.info "Sending digest SMS to #{to}"
    client = Twilio::REST::Client.new(sid, token)
    client.messages.create(from: from, to: to, body: message)
  end

  # TODO: move this to a Textris texter
  def self.send_daily_reminder_sms(member)
    @magic_link_token = member.magic_link.token if
      member.unit.settings(:security).enable_magic_links &&
      member.user.settings(:security).enable_magic_links

    from = ENV['TWILIO_NUMBER']
    to = member.user.phone
    events = member.unit.events.published.imminent
    message = "Hi, #{member.display_first_name}. Today at #{member.unit.name}:"
    events.each do |event|
      message += "\n* #{event.title} on #{event.starts_at.strftime('%A')}"
    end

    message += "\n\nSee the full calendar at https://go.scoutplan.org/units/#{member.unit.id}/events"
    message += "?r=#{@magic_link_token}" if @magic_link_token
    sid = ENV['TWILIO_SID']
    token = ENV['TWILIO_TOKEN']

    client = Twilio::REST::Client.new(sid, token)
    client.messages.create(from: from, to: to, body: message)
  end
end
