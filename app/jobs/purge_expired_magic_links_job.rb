# frozen_string_literal: true

class PurgeExpiredMagicLinksJob < ApplicationJob
  queue_as :default

  def perform(_args)
    MagicLink.expired.destroy_all
  end
end
