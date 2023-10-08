# frozen_string_literal: true

require "capybara/cuprite"

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size:     [1200, 800],
    browser_options: {},
    process_timeout: 10,
    inspector:       true,
    headless: !ENV["HEADLESS"].in?(%w[0 false no]),
  )
end

Capybara.configure do |config|
  config.javascript_driver = :cuprite
  config.server_host = "localhost"
  config.server_port = 3001
  config.app_host = "http://localhost:3001"
end

module CupriteHelpers
  def pause
    page.driver.pause
  end

  def debug(*args)
    page.driver.debug(*args)
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers
end
