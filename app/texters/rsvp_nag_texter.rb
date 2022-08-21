# frozen_string_literal: true

# a Texter for sending digests
class RsvpNagTexter < MemberTexter
  include RsvpHelper
  attr_accessor :event

  def initialize(member, event)
    super(member)
    self.event = event
  end

  def body_text
    renderer.render(template: "member_texter/rsvp_nag", format: "text", assigns: { member: member, event: event, unit: unit })
  end
end
