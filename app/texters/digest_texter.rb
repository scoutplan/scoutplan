# frozen_string_literal: true

# a Texter for sending digests
class DigestTexter < MemberTexter
  def body
    ApplicationController.render(
      template: "texters/digest",
      format: "text",
      assigns: { member: @member, events: events, magic_link_token: magic_link_token }
    )
  end

  private

  def events
    @member.unit.events.published.this_week
  end
end
