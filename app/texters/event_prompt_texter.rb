# frozen_string_literal: true

# a Texter for sending digests
class EventPromptTexter < UserTexter
  include ApplicationHelper

  def initialize(user, event)
    @event = event
    @unit = event.unit
    @member = @unit.members.find_by(user: user)
    @active_family = @member.family(include_self: :prepend).select(&:status_active?)
    @event_presenter = EventPresenter.new(@event, @member, plain_text: true)
    @family_presenter = FamilyPresenter.new(@member)
    super(user)
  end

  def body_text
    name_list = @family_presenter.active_member_names_list
    verb = EventPresenter.new.substantive_verb(@family_presenter.active_member_names)
    service = RsvpService.new(@member, @event)
    renderer.render(template: "user_texter/event_prompt",
                    format: "text",
                    assigns: { user: user, event: @event, unit: @unit,
                               member: @member, event_presenter: @event_presenter,
                               service: service,
                               family_presenter: @family_presenter,
                               verb: verb, name_list: name_list, family_count: @active_family.count })
  end
end
