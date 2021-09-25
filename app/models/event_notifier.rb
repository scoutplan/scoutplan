# frozen_string_literal: true

# notify users under different scenarios
class EventNotifier
  def rsvp_opening(user); end

  def self.after_publish(event)
    return unless event.requires_rsvp

    event.unit.memberships.active.each do |membership|
      user = membership.user
      token = event.rsvp_tokens.find_or_create_by!(user: user)
      EventMailer.with(token: token).token_invitation_email.deliver_later
    end
  end

  def self.after_bulk_publish(unit, events)
    unit.memberships.active.each do |membership|
      user = membership.user
      EventMailer.with(unit: unit, user: user, events: events).bulk_publish_email.deliver_later
    end
  end

  def self.invite_member_to_event(member, event, token)
    EventMailer.with(token: token).token_invitation_email.deliver_later
  end
end
