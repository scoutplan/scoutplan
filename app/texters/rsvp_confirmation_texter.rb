# frozen_string_literal: true

# a Texter for sending RSVP confirmation
class RsvpConfirmationTexter < MemberTexter
  include RsvpHelper
  attr_accessor :event, :rsvp

  def initialize(member, event, rsvp)
    super(member)
    self.event = event
    self.rsvp = rsvp
  end

  def body_text
    if rsvp.accepted?
      renderer.render(template: "member_texter/rsvp_confirmation_accepted", format: "text", assigns: { member: member, event: event })
    else
      renderer.render(template: "member_texter/rsvp_confirmation_declined", format: "text", assigns: { member: member, event: event })
    end
  end
end
