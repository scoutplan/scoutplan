# frozen_string_literal: true

class GlobalOverflowMailbox < ApplicationMailbox
  def process
    Rails.logger.warn "Processing overflow mail for global inbox"
  end
end
