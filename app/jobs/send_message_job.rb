# frozen_string_literal: true

# An ActiveJob for sending Messages asynchronously
class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(*messages)
    
  end
end
