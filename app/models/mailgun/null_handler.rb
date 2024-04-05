# frozen_string_literal: true

class Mailgun::NullHandler
  def initialize(data)
    @data = data
  end

  def process; end
end
