# Runs daily via Solid Queue recurring tasks. Enqueues digest and RSVP nag
# jobs for any units whose scheduled day/hour falls within the next 24 hours,
# using wait_until to fire each one at the right time.
class ScheduledJobDispatcherJob < ApplicationJob
  queue_as :default

  def perform
    Unit.find_each do |unit|
      schedule_digest(unit)
      schedule_rsvp_nag(unit)
    end
  end

  private

  def schedule_digest(unit)
    return unless unit.settings(:communication).digest == "true"

    run_time = SendWeeklyDigestJob.next_run_time(unit)
    return unless run_time.between?(Time.current, 24.hours.from_now)

    SendWeeklyDigestJob.set(wait_until: run_time).perform_later(unit.id)
    Rails.logger.info("ScheduledJobDispatcher: scheduled digest for #{unit.name} at #{run_time}")
  end

  def schedule_rsvp_nag(unit)
    return unless RsvpNagJob.enabled?(unit)

    run_time = RsvpNagJob.next_run_time(unit)
    return unless run_time&.between?(Time.current, 24.hours.from_now)

    RsvpNagJob.set(wait_until: run_time).perform_later(unit.id)
    Rails.logger.info("ScheduledJobDispatcher: scheduled RSVP nag for #{unit.name} at #{run_time}")
  end
end
