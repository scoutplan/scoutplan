# frozen_string_literal: true

require "sidekiq-scheduler"

# class invoked and called by Sidekiq Scheduler to send queued
# messages
class QueuedMessageSender
  include Sidekiq::Worker

  def perform
    Rails.logger.warn { "QueuedMessageSender invoked " }
    Message.queued.each do |message|
      SendMessageJob.perform_later(message)
    end
  end
end
