# frozen_string_literal: true

# a Texter for sending digests
class RsvpLastCallTexter < MemberTexter
  include RsvpHelper
  attr_accessor :events

  def initialize(member, events)
    super(member)
    self.events = events
  end

  def body_text
    renderer.render(template: "member_texter/rsvp_last_call", format: "text", assigns: { member: member, events: events, unit: unit })
  end
end
