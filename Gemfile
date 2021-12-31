# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

# gem 'scout_apm' # needs to be first

gem 'acts_as_list'
gem 'awesome_print'
gem 'aws-sdk-s3', require: false
gem "bootsnap", require: false
gem 'devise'
gem 'faraday'
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'
gem 'humanize'
gem 'ice_cube'
gem 'importmap-rails'
gem 'ledermann-rails-settings'
gem 'lograge'
gem 'mixpanel-ruby'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'pundit'
gem 'rack-cors'
gem 'rails', '~> 7.0.0'
gem 'remote_syslog_logger'
gem 'rexml'
gem 'rubocop', require: false
gem 'sass-rails'
gem 'seedbank'
# gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sidekiq'
gem 'sidekiq_alive'
gem 'sidekiq-scheduler'
# gem 'skylight'
gem 'slim'
gem 'smarter_csv'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem "tailwindcss-rails" #, github: "dorianmariefr/tailwindcss-rails", branch: "minimal"
gem 'timecop'
gem 'twilio-ruby'
gem 'trix'
gem 'turbo-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '~> 2.7', groups: %i[development test]
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'factory_bot_rails', '~> 6.2'
  gem 'web-console', '~> 4.1'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.7'
  gem 'rack-mini-profiler', '~> 2.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring', '~> 2.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'apparition'
  gem 'capybara', '~> 3.35'
  gem 'selenium-webdriver', '~> 3.142'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'simplecov', require: false
  gem 'webdrivers', '~> 4.6'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]