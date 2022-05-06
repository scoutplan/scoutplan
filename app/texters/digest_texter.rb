# frozen_string_literal: true

# a Texter for sending digests
class DigestTexter < MemberTexter
  include RsvpHelper

  def body_text
    renderer.render(
      template: "member_texter/digest",
      format: "text",
      assigns: {
        member: @member,
        service: RsvpService.new(@member),
        events: events,
        open_rsvps: open_rsvps(@member)
      }
    )
  end

  private

  def events
    @member.unit.events.published.this_week
  end
end