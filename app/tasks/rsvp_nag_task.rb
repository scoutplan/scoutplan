# frozen_string_literal: true

# sends a message to a unit's members asking them to RSVP to the
# next event on the calendar where (a) RSVPs are still open,
# (b) event is less than 30 days away, and
# and (c) the member's family RSVP is incomplete
class RsvpNagTask < UnitTask
  TASK_KEY = "rsvp_nag"

  def self.add_to_unit(unit)
    unit.tasks.find_or_create_by(key: TASK_KEY, type: "DailyReminderTask")
  end

  def description
    "RSVP nag"
  end

  def perform
    Rails.logger.info { "Performing RsvpNagTask for #{taskable}"}
    unit.members.each do |member|
      perform_for_member(member)
    rescue StandardError => e
      Rails.logger.error { e.message }
    end
    super
  end

  private

  def perform_for_member(member)
    return unless Flipper.enabled? :rsvp_nag, member

    notifier = RsvpNagNotifier.new(member)
    notifier.perform
  end
end
