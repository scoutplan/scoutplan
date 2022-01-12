# frozen_string_literal: true

# a Texter for sending daily reminders
class DailyReminderTexter < MemberTexter
  def body
    ApplicationController.render(
      template: "texters/daily_reminder",
      format: "text",
      assigns: { member: @member, events: events }
    )
  end

  private

  def events
    @member.unit.events.published.imminent # TODO: move this logic into EventQuery
  end
end
