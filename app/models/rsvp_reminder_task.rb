# frozen_string_literal: true

# sends RSVP reminders to members
class RsvpReminderTask < UnitTask
  def description
    I18n.t("tasks.rsvp_reminders")
  end

  def perform
    Time.use_zone(unit.time_zone) do
      send_rsvp_reminders(5.days.from_now, via: :email)
      send_rsvp_reminders(2.days.from_now, via: :sms)
      send_rsvp_reminders(1.days.from_now, via: :email_and_sms)
    end
    super
  end

  private

  def send_rsvp_reminders(rsvp_closes_at, via: :email_and_sms)
  end
end
