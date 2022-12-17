# frozen_string_literal: true

# a Texter for sending latest RSVPs to event organizers
class EventOrganizerDigestTexter < MemberTexter
  def initialize(member, event, rsvps, new_rsvps, last_ran_at)
    @event = event
    @rsvps = rsvps
    @new_rsvps = new_rsvps
    @last_ran_at = last_ran_at
    super(member)
  end

  def body_text
    renderer.render(template: "member_texter/event_organizer_digest",
                    format: "text",
                    assigns: { member: @member, event: @event, rsvps: @rsvps,
                               new_rsvps: @new_rsvps, last_ran_at: @last_ran_at })
  end
end
