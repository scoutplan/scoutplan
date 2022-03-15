# frozen_string_literal: true

# sends RSVP reminders to members
class RsvpReminder
  def initialize(unit)
    @unit = unit
  end

  def send_to_members(days_prior: 5.days, send_via: :email)
    Time.use_zone(@unit.time_zone) do
      return unless @unit.settings(:communication).rsvp_reminders

      @days_prior = days_prior
      @send_via = send_via

      @unit.events.published.future.find_each do |event|
        send_for_event(event)
      end
    end
  end

  private

  def send_for_event(event)
    return unless event.starts_at = Time.current
  end
end
