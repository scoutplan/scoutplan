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
    find_events
    send_digests if @events.count.positive?
    super
  end

  private

  def find_events
    unit.events.future.select { |e| e.organizers.present? }
  end

  def send_digest(event, organizer)
    new_rsvps = event.rsvps.where("created_at > ?", last_ran_at || event.created_at).group_by(&:response)
    OrganizerMailer.with(event: event, organizer: organizer, new_rsvps: new_rsvps)
                   .daily_digest_email.send_later
  end

  def send_digests
    @events.each do |event|
      event.organizers.each do |organizer|
        next unless organizer.settings[:communication].event_organizer_digest

        send_digest(event, organizer)
      end
    end
  end
end
