# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  config.web_console.permissions = "0.0.0.0/0"

  config.hosts = [
    IPAddr.new("0.0.0.0/0"),        # All IPv4 addresses.
    IPAddr.new("::/0"),             # All IPv6 addresses.
    "localhost",                    # The localhost reserved domain.
    "scoutplan.ngrok.io",
    ENV["RAILS_DEVELOPMENT_HOSTS"]
  ]

  config.hosts.clear
  config.force_ssl = true
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :digitalocean

  config.action_mailbox.ingress = :mailgun

  # MAILER SETTINGS
  config.action_mailer.raise_delivery_errors  = true
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_caching        = false
  config.action_mailer.default_url_options    = { host: "go.scoutplan-local.org", protocol: :https }
  config.action_mailer.smtp_settings          = { address: "mailcatcher", port: 1025 }

  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_adapter = :sucker_punch

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # RGB 24 August 2021
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
  config.after_initialize do
    Bullet.enable = true
    # Bullet.sentry = true
    # Bullet.alert = true
    Bullet.bullet_logger = true
    # Bullet.console = true
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }
    # Bullet.rails_logger = true
    # Bullet.honeybadger = true
    # Bullet.bugsnag = true
    # Bullet.appsignal = true
    # Bullet.airbrake = true
    # Bullet.rollbar = true
    # Bullet.add_footer = true
    # Bullet.skip_html_injection = false
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware', ['my_file.rb', 'my_method'], ['my_file.rb', 16..20] ]
    # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
  end  
end
# rubocop:enable Metrics/BlockLength