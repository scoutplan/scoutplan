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

  desc "Set message senders"
  task set_message_senders: :environment do
    Message.all.each do |message|
      message.update!(sender: message.author)
    end
  end
end
