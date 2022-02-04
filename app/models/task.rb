# frozen_string_literal: true

require "sidekiq-scheduler"

# Task encapsulates things that occur on a recurring
# basis, including scheduling, next run time, last run time,
# etc.
#
# Subclass the Task class to do something specific.
# Conversely, don't invoke this base class directly.
#
class Task < ApplicationRecord
  include Sidekiq::Worker
  belongs_to :taskable, polymorphic: true

  # Require a key
  validates_presence_of :key

  # Prevent duplicate keys for a given Taskable
  validates_uniqueness_of :key, scope: :taskable

  # override in subclasses
  def description
    I18n.t("tasks.undefined_description")
  end

  # override `perform` in subclasses. Make
  # sure to call `super` in subclasses or, alternately,
  # call set_high_watermark from subclasses
  def perform
    set_high_watermark
  end

  # if we're calling every minute, most of the time there's nothing to do
  #
  def perform_on_schedule
    Rails.logger.warn { "Next runs at #{next_runs_at}" }
    perform if time_to_run?
  end

  def time_to_run?
    return false unless schedule_hash.present?

    DateTime.now.after?(next_runs_at)
  end

  # When should it run next? Returns a DateTime
  def next_runs_at
    schedule.next_occurrence(last_ran_at || 1.week.ago)
  end

  # set `last_ran_at`
  #
  def set_high_watermark
    update! last_ran_at: DateTime.now
  end

  # Make or rehydrate a Schedule object and store as instance var
  #
  def schedule
    @schedule ||= schedule_hash.present? ? IceCube::Schedule.from_yaml(schedule_hash) : IceCube::Schedule.new

    # trap unparsable string errors, which tend to manifest as `undefined method`
  rescue NoMethodError
    @schedule = IceCube::Schedule.new
  end

  # An attribute setter doesn't make sense in this context, so we'll stand up an
  # explicit `save` method for classes to call when they're done manipulating the
  # Schedule object
  #
  def save_schedule
    update! schedule_hash: schedule.to_yaml
  end

  def clear_schedule
    schedule.remove_recurrence_rule(schedule.recurrence_rules.first) while schedule.recurrence_rules.count.positive?
  end

  # Entrypoint for cron or other task runner. The assumption
  # is that this gets called frequently (e.g. every 60 seconds).
  #
  # It iterates over all Tasks, calling perform_on_schedule for each.
  #
  def self.perform_all_on_schedule
    Task.all.each(&:perform_on_schedule)
  end
end
