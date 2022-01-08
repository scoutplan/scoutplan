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

  # override `perform` in subclasses. Make
  # sure to call `super` in subclasses or, alternately,
  # call set_high_watermark from subclasses
  def perform
    set_high_watermark
  end

  # if we're calling every minute, most of the time there's nothing to do
  #
  def perform_on_schedule
    perform if time_to_run?
  end

  # set `last_ran_at`
  #
  def set_high_watermark
    update! last_ran_at: DateTime.now
  end

  # When should it run next? Returns a DateTime
  def next_runs_at
    schedule.next_occurrence(last_ran_at || 1.week.ago)
  end

  def time_to_run?
    DateTime.now.after?(next_runs_at)
  end

  def schedule
    @schedule ||= schedule_hash.present? ? IceCube::Schedule.from_hash(schedule_hash) : IceCube::Schedule.new
  end

  # Entrypoint for cron or other task runner: Task.perform_all. The assumption
  # is that this gets called frequently (e.g. every 60 seconds).
  #
  # It iterates across all jobs, calling perform_on_schedule for each.
  #
  def self.perform_all
    return if @@running

    @running = true
    Task.all.each(&:perform_on_schedule)
    @running = false
  end
end
