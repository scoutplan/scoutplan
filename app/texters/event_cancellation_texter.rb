# frozen_string_literal: true

# a Texter for event cancellations
class EventCancellationTexter < ApplicationTexter
  def initialize(event, member)
    @event = event
    @member = member
    super()
  end

  def body
    @body ||= renderer.render(
      template: "member_texter/event_cancellation",
      format: "text",
      assigns: { member: @member, events: events }
    )
  end
end
