class ComputeChildContactabilityJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform(*args)
    args.first.children.each do |child|
      child.compute_contactability!
      puts "Computed contactability for #{child.user.display_name} in #{child.unit.name} (#{child.id}): #{child.contactable_via_email}, #{child.contactable_via_sms}, #{child.contactable}"
    end
  rescue StandardError => e
    Rails.logger.error "Error computing contactability for children: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Optionally, you can re-raise the error if you want to handle it further up the chain
    # raise e
  ensure
    puts "Finished computing contactability for children of #{args.first.user.display_name} in #{args.first.unit.name} (#{args.first.id})"
    # Ensure that the job is marked as complete even if an error occurs
    # This is useful for monitoring and debugging purposes
    Rails.logger.info "ComputeChildContactabilityJob completed for #{args.first.user.display_name} in #{args.first.unit.name} (#{args.first.id})"
    # You can also add any additional cleanup or logging here if needed
  end
  # rubocop:enable Metrics/AbcSize
end
