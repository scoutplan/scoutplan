# frozen_string_literal: true

require "sidekiq-scheduler"

# This is a Class that can be instantiated by Sidekiq Scheduler which,
# in turn, send out RSVP reminders five days before RSVP closure.
class RsvpRemindersFiveDays
  include Sidekiq::Worker

  def perform
    Rails.logger.warn { "RsvpRemindersFiveDays invoked" }
    Unit.all.find_each do |unit|
      reminder = RsvpReminder.new(unit)
      reminder.send_to_members(5.days, send_via: :email)
    end
  end
end
