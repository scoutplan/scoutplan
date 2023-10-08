# frozen_string_literal: true

require "sidekiq-scheduler"

class TaskRunner
  include Sidekiq::Worker

  def perform
    Rails.logger.warn { "TaskRunner invoked" }
    Task.perform_all_on_schedule
  end
end
