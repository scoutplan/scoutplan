# frozen_string_literal: true

# a Texter for sending digests
class EventListTexter < UserTexter
  def initialize(user, events)
    @events = events
    super(user)
  end

  def body_text
    renderer.render(template: "user_texter/event_list",
                    format: "text",
                    assigns: { user: user, events: @events, unit_count: user.units.count })
  end

  #-------------------------------------------------------------------------
  private

  def events
    user.events.upcoming
  end
end
