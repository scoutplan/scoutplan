class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!

  def new_session_path(scope)
    new_user_session_path
  end
end
