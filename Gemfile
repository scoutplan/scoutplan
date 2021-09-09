source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'awesome_print', "~> 1.9"
gem 'bootsnap', '~> 1.8', require: false
gem 'devise', "~> 4.8"
gem 'faraday', "~> 1.7"
gem 'jbuilder', '~> 2.11'
gem 'pg', "~> 1.2"
gem 'puma', '~> 5.4'
gem 'pundit', "~> 2.1"
gem 'rails', '~> 6.1'
gem 'rails-observers', "~> 0.1"
gem 'rexml', "~> 3.2"
gem 'sass-rails', '~> 6.0'
gem "sentry-ruby"
gem "sentry-rails"
gem 'sidekiq', '~> 6.1'
gem 'seedbank', "~> 0.5"
gem 'skylight'
gem 'slim', "~> 4.1"
gem 'trix', "~> 0.10"
gem 'turbolinks', '~> 5.2'
gem 'webpacker', '~> 5.4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', "~> 11.1", platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails', "~> 2.7", groups: [:development, :test]
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'factory_bot_rails', "~> 6.2"
  gem 'web-console', '~> 4.1'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.3'
  gem 'listen', '~> 3.7'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', "~> 2.1"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.35'
  gem 'selenium-webdriver', "~> 3.142"
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers', "~> 4.6"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
