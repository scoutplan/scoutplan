# frozen_string_literal: true

# a Texter for sending digests
class EventPromptTexter < UserTexter
  def initialize(user, event)
    @event = event
    @unit = event.unit
    @member = @unit.members.find_by(user: user)
    @presenter = EventPresenter.new(@event, @member)
    super(user)
  end

  def body_text
    renderer.render(template: "user_texter/event_prompt",
                    format: "text",
                    assigns: { user: user, event: @event, unit: @unit,
                               member: @member, presenter: @presenter })
  end
end
