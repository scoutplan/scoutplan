# frozen_string_literal: true

# a Texter for sending digests
class DigestTexter < MemberTexter
  def body
    @body ||= renderer.render(
      template: "member_texter/digest",
      format: "text",
      assigns: { member: @member, events: events }
    )
  end

  private

  def events
    @member.unit.events.published.this_week
  end
end
