class ComputeChildContactabilityJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    Rails.logger.error("ComputeChildContactabilityJob failed: #{exception.message}")
  end

  def perform(*args)
    args.first.children.each(&:compute_contactability!)
  end
end
