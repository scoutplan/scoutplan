source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.8"

gem "rails", "~> 8.1.0"

gem "scout_apm"

gem "active_storage_validations"
gem "acts_as_list"
gem "acts-as-taggable-on"
gem "ahoy_email"
gem "ahoy_matey"
gem "auto_strip_attributes"
gem "aws-sdk-s3", require: false
gem "blazer"
gem "bootsnap", require: false
gem "chroma"
gem "combine_pdf"
gem "convert_api"
gem "coveralls_reborn", require: false
gem "daypack", git: "https://github.com/scoutplan/daypack.git"
gem "devise"
gem "flamegraph"
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"
gem "honeybadger", "~> 5.0"
gem "humanize"
gem "icalendar"
gem "ice_cube", github: "ice-cube-ruby/ice_cube", ref: "6b97e77c106cd6662cb7292a5f59b01e4ccaedc6"
gem "image_processing"
gem "importmap-rails"
gem "ledermann-rails-settings"
gem "lograge"
gem "loofah", ">= 2.19.1"
gem "nokogiri", ">= 1.14.3"
gem "noticed"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "openweathermap"
gem "paper_trail"
gem "pg"
gem "phony_rails"
gem "postmark-rails"
gem "prawn"
gem "puma", "~> 6.0"
gem "pundit"
gem "rack-attack"
gem "rack-cors"
gem "rails-html-sanitizer", ">= 1.4.4"
gem "redis", "~> 5.0"
gem "remote_syslog_logger"
gem "rest-client"
gem "ruby-openai"
gem "sanitize", ">= 6.0.2"
gem "sentry-ruby"
# Solid Queue/Cache for database-backed jobs and caching
gem "mission_control-jobs"
gem "slim"
gem "smarter_csv"
gem "solid_cache"
gem "solid_queue"
gem "sprockets-rails"
gem "stimulus-rails"
gem "StreetAddress"
gem "stripe"
gem "tailwindcss-rails"
gem "timecop"
gem "turbo-rails"
gem "twilio-ruby"

gem "rack-mini-profiler", "~> 2.3"
gem "stackprof"

gem "memory_profiler"

group :development, :test do
  gem "byebug", "~> 11.1", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", "~> 2.7", groups: %i[development test]
  gem "rspec-rails", "~> 6.0"
  gem "standard", ">= 1.0"
end

group :development do
  gem "better_mailer_previews"
  gem "factory_bot_rails", "~> 6.2"
  gem "listen", "~> 3.7"
  gem "pry-rails"
  gem "ruby-lsp"
  gem "web-console", "~> 4.1"
end

group :test do
  gem "capybara"
  gem "capybara_test_helpers"
  gem "cuprite"
  gem "faker"
  gem "launchy"
  gem "rack_session_access"
  gem "simplecov", require: false
  gem "vcr"
  gem "webmock"
end

gem "rack", "~> 2.2"
