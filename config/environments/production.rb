# frozen_string_literal: true

Rails.application.default_url_options = {
  host: ENV["SCOUTPLAN_HOST"],
  protocol: ENV["SCOUTPLAN_PROTOCOL"]
}

Rails.application.configure do
  config.logger = RemoteSyslogLogger.new(ENV["LOGGER_HOST"], ENV["LOGGER_PORT"])

  config.hosts << "go.scoutplan.org"
  config.hosts << "kit.fontawesome.com"
  config.hosts << ENV["RAILS_PRODUCTION_HOSTS"]
  config.hosts << /10\.\d+\.\d+\.\d+/ # internal IP addresses...leave this here

  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false

  config.action_controller.perform_caching = true

  config.require_master_key = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.assets.css_compressor = nil

  config.assets.compile = true

  config.active_storage.service = :digitalocean

  config.force_ssl = true

  config.ssl_options = { redirect: false } # disable redirect since the LB handles it

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL") { "info" }

  config.log_tags = [:request_id]

  config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }

  config.active_job.queue_adapter = :sidekiq

  config.action_mailbox.ingress = :mailgun 

  config.action_mailer.raise_delivery_errors  = true
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_caching        = false
  config.action_mailer.default_url_options    = {
    host:     ENV["SCOUTPLAN_HOST"],
    protocol: ENV["SCOUTPLAN_PROTOCOL"]
  }
  config.action_mailer.smtp_settings = {
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    domain:               ENV["SMTP_DOMAIN"],
    address:              ENV["SMTP_ADDRESS"],
    port:                 ENV["SMTP_PORT"],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.active_support.disallowed_deprecation = :log

  config.active_support.disallowed_deprecation_warnings = []

  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
