# frozen_string_literal: true

namespace :sp do
  desc "Create event reminder Jobs"
  task create_event_reminder_jobs: :environment do
    puts "Processing #{Event.count} events..."
    puts "#{Sidekiq::ScheduledSet.new.size} jobs scheduled"
    Event.all.each(&:create_reminder_job!)
    puts "#{Sidekiq::ScheduledSet.new.size} jobs scheduled"
  end

  # https://github.com/sidekiq/sidekiq/wiki/API#scheduled
  desc "Delete scheduled event reminder Jobs"
  task delete_event_reminder_jobs: :environment do
    ss = Sidekiq::ScheduledSet.new
    puts "Processing #{ss.size} jobs..."
    ss.scan("EventReminderJob").each(&:delete)
    puts "#{ss.size} jobs remaining"
  end
end
