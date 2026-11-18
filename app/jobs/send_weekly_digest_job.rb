class SendWeeklyDigestJob < ApplicationJob
  DEFAULT_DAY_OF_WEEK = "Sunday".freeze
  DEFAULT_HOUR_OF_DAY = 9

  queue_as :default

  def perform(unit_id)
    unit = Unit.find(unit_id)
    return unless unit.settings(:communication).digest == "true"
    return if SendWeeklyDigestJob.ran_recently?(unit)

    Rails.logger.info("SendWeeklyDigestJob: sending digest for #{unit.name}")
    note_html = unit.digest_note_html
    note_version = unit.rich_text_digest_note&.updated_at
    WeeklyDigestNotifier.with(unit: unit, digest_note_html: note_html).deliver(unit.members)
    unit.settings(:communication).update!(digest_last_ran_at: DateTime.current)
    unit.clear_digest_note!(sent_version: note_version) if note_html.present? && !unit.keep_digest_note?
  end

  # See RsvpNagJob: the dispatcher may enqueue the same weekly run more than once, and a digest
  # sent twice reaches every member of the unit.
  MIN_RUN_INTERVAL = 12.hours

  def self.ran_recently?(unit)
    last = last_ran_at(unit)
    last.present? && last > MIN_RUN_INTERVAL.ago
  end

  def self.last_ran_at(unit)
    raw = unit.settings(:communication).digest_last_ran_at
    return nil if raw.blank?

    raw.is_a?(String) ? Time.zone.parse(raw) : raw.to_time
  rescue ArgumentError, TypeError, NoMethodError
    nil
  end

  def self.next_run_time(unit)
    Time.zone = unit.time_zone
    day_of_week = unit.settings(:communication).digest_day_of_week.downcase
    hour_of_day = unit.settings(:communication).digest_hour_of_day.to_i
    next_occurring(DateTime.current, day_of_week, hour_of_day).utc
  end
end
