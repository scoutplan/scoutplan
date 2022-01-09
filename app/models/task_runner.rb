# frozen_string_literal: true

require "sidekiq-scheduler"

# This is a Class that can be instantiated by Sidekiq Scheduler which,
# in turn, runs all Tasks.
#
class TaskRunner
  include Sidekiq::Worker

  def perform
    Rails.logger.warn { "TaskRunner invoked "}
    Task.perform_all_on_schedule
  end
end
