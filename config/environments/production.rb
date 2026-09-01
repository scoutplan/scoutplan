# frozen_string_literal: true

Rails.application.default_url_options = {
  host: ENV["SCOUTPLAN_HOST"],
  protocol: ENV["SCOUTPLAN_PROTOCOL"]
}

# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  # Use STDOUT logger for Docker/Kamal, with optional remote syslog
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::Logger.new($stdout)
      .tap { |logger| logger.formatter = ::Logger::Formatter.new }
      .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  else
    config.logger = RemoteSyslogLogger.new(ENV["LOGGER_HOST"], ENV["LOGGER_PORT"])
  end

  config.hosts << "go.scoutplan.org"
  config.hosts << "new.scoutplan.org"
  config.hosts << "kit.fontawesome.com"
  config.hosts << ENV["RAILS_PRODUCTION_HOSTS"]
  config.hosts << /10\.\d+\.\d+\.\d+/ # internal IP addresses...leave this here
  config.hosts << /.*\.sites\.scoutplan\.org/
  config.hosts << "new.troop2scarsdale.org" # unit site custom domain; see WebController::CUSTOM_DOMAINS
  # Allow all internal Docker/Kamal health check requests
  config.hosts << /[a-f0-9-]+/ # Docker container IDs and hostnames
  config.hosts << /localhost(:\d+)?/
  config.hosts << /127\.0\.0\.1(:\d+)?/
  config.hosts << /\d+\.\d+\.\d+\.\d+(:\d+)?/ # Any IP address (for Docker network)
  config.hosts << /134\.209\.\d+\.\d+.*/ # DigitalOcean droplet IPs with optional hostname suffix

  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false

  config.action_controller.perform_caching = true

  config.require_master_key = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.active_storage.service = :digitalocean

  config.force_ssl = true

  config.ssl_options = { redirect: false } # disable redirect since the LB handles it

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.log_tags = [:request_id]

  # Phase 1: Keep Redis cache while preparing for Solid Cache migration
  # TODO: Change to :solid_cache_store in Phase 4
  config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }

  # Phase 3: Solid Queue for background jobs (database-backed, no Redis dependency)
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :primary } }

  config.action_mailbox.ingress = :mailgun

  # STOPGAP (2026-08-31): Postmark has been accepting messages -- returning ErrorCode 0 and a
  # MessageID -- without recording or delivering them since 2026-08-09, following the compromise
  # of the old server token. Escalation is open with their support. Deliver over SMTP whenever
  # SMTP_ADDRESS is set; clear that variable and redeploy to go straight back to Postmark.
  if ENV["SMTP_ADDRESS"].present?
    smtp_port = ENV.fetch("SMTP_PORT", 587).to_i

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_ADDRESS"],
      port:                 smtp_port,
      domain:               ENV.fetch("SMTP_DOMAIN", "scoutplan.org"),
      user_name:            ENV["SMTP_USERNAME"],
      password:             ENV["SMTP_PASSWORD"],
      authentication:       (:plain if ENV["SMTP_USERNAME"].present?),
      # 465 is implicit TLS; 587 negotiates with STARTTLS.
      ssl:                  (true if smtp_port == 465),
      enable_starttls_auto: (true unless smtp_port == 465),
      # Without these a hung SMTP connection ties up a Solid Queue worker thread indefinitely.
      open_timeout:         10,
      read_timeout:         20
    }.compact
  else
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV.fetch("POSTMARK_API_TOKEN", nil) }
  end

  # Silent delivery failures are why the outage above ran for three weeks behind green job logs.
  # Mail is sent with deliver_later, so raising means Solid Queue retries and then records the
  # failure in solid_queue_failed_executions, and Honeybadger sees it.
  config.action_mailer.raise_delivery_errors = true

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
# rubocop:enable Metrics/BlockLength
