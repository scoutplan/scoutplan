class ComputeChildContactabilityJob < ApplicationJob
  queue_as :default

  # The member can be deleted between enqueue and perform. Since globalid 1.4.0,
  # ActiveJob looks arguments up with GlobalID::Locator.fetch, which raises its own
  # GlobalID::Locator::RecordNotFound rather than letting Model.find's escape, so a
  # missing record now arrives as ActiveJob::DeserializationError::RecordNotFound
  # with no ActiveRecord::RecordNotFound anywhere in its cause chain -- meaning the
  # rescue_from below no longer sees it.
  discard_on(ActiveJob::DeserializationError::RecordNotFound) do |job, exception|
    Rails.logger.error("#{job.class.name} failed: #{exception.message}")
  end

  # Still needed for records that go missing while perform is running.
  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    Rails.logger.error("ComputeChildContactabilityJob failed: #{exception.message}")
  end

  def perform(*args)
    args.first.children.each(&:compute_contactability!)
  end
end
