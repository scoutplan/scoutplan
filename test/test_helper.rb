# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# factory_bot_rails currently sits in the :development group (the RSpec suite reaches it the same
# way, from spec_helper), so it is not auto-required by Bundler under RAILS_ENV=test. It has to be
# loaded *before* config/environment so its railtie is registered and FactoryBot.find_definitions
# runs during initialization. Definitions are picked up from spec/factories by default.
require "factory_bot_rails"

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include ActiveJob::TestHelper

    # No fixtures - everything is built with the factories under spec/factories.
    self.use_transactional_tests = true
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TURBO_STREAM_HEADERS = { "Accept" => Mime[:turbo_stream].to_s }.freeze
end
