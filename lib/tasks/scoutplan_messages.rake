# frozen_string_literal: true

namespace :scoutplan_messages do
  desc "Send digests"
  task send_digests: :environment do
    DigestSender.new.perform
  end

  desc "Send daily reminders"
  task send_daily_reminders: :environment do
    DailyReminderSender.new.perform
  end
end
