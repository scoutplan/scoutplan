# frozen_string_literal: true

# Rake tasks for migrating from Sidekiq to Solid Queue
# These tasks rebuild forward-scheduled jobs after switching queue adapters
namespace :jobs do
  desc "Re-enqueue all forward-scheduled jobs for Solid Queue migration"
  task rebuild_scheduled_jobs: :environment do
    puts "=== Rebuilding scheduled jobs for Solid Queue ==="
    puts "Started at: #{Time.current}"
    puts

    Rake::Task["jobs:rebuild_event_reminders"].invoke
    Rake::Task["jobs:rebuild_rsvp_last_calls"].invoke
    Rake::Task["jobs:rebuild_digest_jobs"].invoke
    Rake::Task["jobs:rebuild_rsvp_nag_jobs"].invoke
    Rake::Task["jobs:rebuild_scheduled_messages"].invoke

    puts
    puts "=== Job rebuild complete ==="
    puts "Finished at: #{Time.current}"
  end

  desc "Re-enqueue event reminder jobs for published future events"
  task rebuild_event_reminders: :environment do
    puts "Re-enqueuing event reminder jobs..."
    count = 0

    Event.published.where("starts_at > ?", Time.current).find_each do |event|
      event.enqueue_reminder_job!
      count += 1
      print "." if count % 10 == 0
    end

    puts
    puts "  Enqueued #{count} event reminder jobs"
  end

  desc "Re-enqueue RSVP last call jobs for events with open RSVPs"
  task rebuild_rsvp_last_calls: :environment do
    puts "Re-enqueuing RSVP last call jobs..."
    count = 0

    Event.published.where("starts_at > ?", Time.current).find_each do |event|
      next unless event.requires_rsvp? && event.rsvp_closes_at&.future?

      event.enqueue_last_call_job!
      count += 1
      print "." if count % 10 == 0
    end

    puts
    puts "  Enqueued #{count} RSVP last call jobs"
  end

  desc "Re-enqueue weekly digest jobs for all units with digest enabled"
  task rebuild_digest_jobs: :environment do
    puts "Re-enqueuing weekly digest jobs..."
    count = 0

    Unit.find_each do |unit|
      if unit.settings(:communication).digest == "true"
        SendWeeklyDigestJob.schedule_next_job(unit)
        count += 1
        print "."
      end
    end

    puts
    puts "  Enqueued #{count} weekly digest jobs"
  end

  desc "Re-enqueue RSVP nag jobs for all units with nag enabled"
  task rebuild_rsvp_nag_jobs: :environment do
    puts "Re-enqueuing RSVP nag jobs..."
    count = 0

    Unit.find_each do |unit|
      if RsvpNagJob.should_run?(unit)
        RsvpNagJob.schedule_next_job(unit)
        count += 1
        print "."
      end
    end

    puts
    puts "  Enqueued #{count} RSVP nag jobs"
  end

  desc "Re-enqueue scheduled messages that haven't been sent yet"
  task rebuild_scheduled_messages: :environment do
    puts "Re-enqueuing scheduled messages..."
    count = 0

    Message.where(status: [:queued, :outbox]).where("send_at > ?", Time.current).find_each do |message|
      message.create_send_job!
      count += 1
      print "."
    end

    puts
    puts "  Enqueued #{count} scheduled message jobs"
  end

  desc "Show current job counts (works with both Sidekiq and Solid Queue)"
  task status: :environment do
    puts "=== Job Queue Status ==="
    puts

    adapter = Rails.application.config.active_job.queue_adapter.to_s

    if adapter == "sidekiq"
      require "sidekiq/api"
      stats = Sidekiq::Stats.new

      puts "Queue Adapter: Sidekiq"
      puts "  Processed: #{stats.processed}"
      puts "  Failed: #{stats.failed}"
      puts "  Enqueued: #{stats.enqueued}"
      puts "  Scheduled: #{stats.scheduled_size}"
      puts "  Retry: #{stats.retry_size}"
      puts "  Dead: #{stats.dead_size}"
      puts

      if stats.scheduled_size > 0
        puts "Scheduled jobs by class:"
        scheduled = Sidekiq::ScheduledSet.new
        counts = Hash.new(0)
        scheduled.each { |job| counts[job.klass] += 1 }
        counts.sort_by { |_, v| -v }.each { |klass, count| puts "  #{klass}: #{count}" }
      end
    elsif adapter == "solid_queue"
      puts "Queue Adapter: Solid Queue"
      puts "  Jobs: #{SolidQueue::Job.count}"
      puts "  Scheduled: #{SolidQueue::ScheduledExecution.count}"
      puts "  Ready: #{SolidQueue::ReadyExecution.count}"
      puts "  Claimed: #{SolidQueue::ClaimedExecution.count}"
      puts "  Failed: #{SolidQueue::FailedExecution.count}"
      puts "  Finished: #{SolidQueue::Job.where.not(finished_at: nil).count}"
      puts

      if SolidQueue::ScheduledExecution.count > 0
        puts "Scheduled jobs by class:"
        SolidQueue::Job.joins(:scheduled_execution)
                       .group(:class_name)
                       .count
                       .sort_by { |_, v| -v }
                       .each { |klass, count| puts "  #{klass}: #{count}" }
      end
    else
      puts "Queue Adapter: #{adapter}"
      puts "  (Status details not available for this adapter)"
    end
  end
end
