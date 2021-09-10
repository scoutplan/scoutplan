class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!
  # before_action :set_cors_headers

  def new_session_path(scope)
    new_user_session_path
  end

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*.fontawesome.com'
  end
end
