# frozen_string_literal: true

# a Texter for sending digests
class DigestTexter < MemberTexter
  def body
    @body ||= renderer.render(
      template: "member_texter/digest",
      format: "text",
      assigns: { member: @member, events: events, magic_link_token: magic_link_token }
    )
  end

  private

  def renderer
    ApplicationController.renderer.new(
      http_host: ENV["SCOUTPLAN_HOST"],
      https: ENV["SCOUTPLAN_PROTOCOL"] == "https"
    )
  end

  def events
    @member.unit.events.published.this_week
  end
end
