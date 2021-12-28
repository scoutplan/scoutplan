# frozen_string_literal: true

# custom error handler. The route is set in routes.rb and the
# behavior is configured in application.rb
class ErrorsController < ApplicationController
  def show
    puts '***************'
    puts '***************'
    puts '***************'
    puts '***************'
    puts params[:code]
    status_code = params[:code] || 500
    render status_code.to_s, status: status_code
  end
end
