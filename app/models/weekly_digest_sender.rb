# frozen_string_literal: true

require 'sidekiq-scheduler'

# job called via cron-like mechanism to send weekly digests
# (in this case, sidekiq-scheduler)
class WeeklyDigestSender
  include Sidekiq::Worker

  def perform
    puts 'Sending digests...'

    Unit.all.each do |unit|
      next unless unit.settings(:communication).weekly_digest.present?
      next unless time_to_run(unit)

      unit.members.each do |member|
        next unless Flipper.enabled? :weekly_digest, member

        MemberNotifier.send_digest(member)
      end

      unit.settings(:communication).last_digest_sent_at = DateTime.now
    end
  end

  # is it time for this unit to run its weekly digest?
  # hardwired for 10 AM on Sunday
  def time_to_run(unit)
    Time.zone = unit.settings(:locale).time_zone
    right_now = Time.zone.now
    right_now.sunday? && right_now.hour == 10 && right_now.minute = 0
  end
end
