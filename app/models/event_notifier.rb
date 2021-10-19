# frozen_string_literal: true

# notify users under different scenarios
class EventNotifier
  def rsvp_opening(user); end

  def self.after_publish(event)
    return unless event.requires_rsvp

    event.unit.members.active.each do |member|
      next unless member.contactable?
      next unless Flipper.enabled? :receive_event_publish_notice, member

      token = event.rsvp_tokens.find_or_create_by!(unit_membership: member)
      EventMailer.with(token: token, member: token.member).token_invitation_email.deliver_later
    end
  end

  def self.after_bulk_publish(unit, events)
    unit.memberships.active.each do |member|
      next unless Flipper.enabled? :receive_bulk_publish_notice, member

      ap '$$$$$'
      ap member

      user = member.user
      EventMailer.with(unit: unit, user: user, events: events, member: member).bulk_publish_email.deliver_later
    end
  end

  def self.invite_member_to_event(token)
    EventMailer.with(token: token, member: token.member).token_invitation_email.deliver_later
  end

  def self.send_rsvp_confirmation(rsvp)
    return unless rsvp.contactable?
    return unless Flipper.enabled? :receive_rsvp_confirmation, rsvp.member

    EventMailer.with(rsvp: rsvp, member: rsvp.member).rsvp_confirmation_email.deliver_later
  end
end
