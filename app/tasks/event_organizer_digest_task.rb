# frozen_string_literal: true

# Recurring task to send daily reminders to members
class EventOrganizerDigestTask < UnitTask
  def initialize(unit)
    @unit = unit
    super
  end

  def description
    "Daily digest for event organizers"
  end

  def perform
    Time.zone = unit.settings(:locale).time_zone
    @unit.members.each do |member|
      notifier = MemberNotifier.new(member)
      notifier.send_event_organizer_digest(last_ran_at)
    end
    super
  end
end
