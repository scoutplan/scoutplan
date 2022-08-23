# frozen_string_literal: true

# sends a message to a unit's members asking them to RSVP to the
# next event on the calendar where (a) RSVPs are still open,
# (b) event is less than 30 days away, and
# and (c) the member's family RSVP is incomplete
class RsvpNagTask < UnitTask
  def perform
    unit.members.each do |member|
      notifier = RsvpNagNotifier.new(member)
      notifier.perform
    end
  end
end
