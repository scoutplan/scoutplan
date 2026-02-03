# frozen_string_literal: true

# Job to purge orphaned file uploads from Active Storage
# This runs daily via Solid Queue's recurring jobs (config/recurring.yml)
# or via sidekiq-scheduler (config/sidekiq.yml) during the migration period
class PurgeOrphanedUploadsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info { "Purging orphaned file uploads" }
    purged_count = 0

    ActiveStorage::Blob.unattached.find_each do |blob|
      blob.purge_later
      purged_count += 1
    end

    Rails.logger.info { "Queued #{purged_count} orphaned blobs for purging" }
  end
end
