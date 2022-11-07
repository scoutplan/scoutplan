# frozen_string_literal: true

# a Texter for sending digests
class EventPromptTexter < UserTexter
  include ApplicationHelper

  def initialize(user, event)
    @event = event
    @unit = event.unit
    @member = @unit.members.find_by(user: user)
    @active_family = @member.family(include_self: :prepend).select(&:status_active?)
    @event_presenter = EventPresenter.new(@event, @member)
    @family_presenter = FamilyPresenter.new(@member)
    super(user)
  end

  def body_text
    verb = EventPresenter.new.substantive_verb(@active_family)
    names = @family_presenter.active_member_names
    renderer.render(template: "user_texter/event_prompt",
                    format: "text",
                    assigns: { user: user, event: @event, unit: @unit,
                               member: @member, event_presenter: @event_presenter,
                               family_presenter: @family_presenter,
                               verb: verb, names: names })
  end
end
