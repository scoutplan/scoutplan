# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Scoutplan
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec, request_specs: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.exceptions_app = self.routes # tee up custom errors
    config.active_record.yaml_column_permitted_classes = [Symbol, DateTime, Date, Time]
    config.active_storage.variant_processor = :vips
    config.active_storage.queues.analysis = :active_storage_analysis
    config.action_mailer.delivery_job = "ScoutplanMailDeliveryJob"
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
