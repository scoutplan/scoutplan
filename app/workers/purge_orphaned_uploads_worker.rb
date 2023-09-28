# frozen_string_literal: true

require "sidekiq-scheduler"

class PurgeOrphanedUploadsWorker
  include Sidekiq::Worker

  queue_as :default

  def perform
    Rails.logger.info { "Purging orphaned file uploads" }
    ActiveStorage::Blob.unattached.each(&:purge_later)
  end
end
