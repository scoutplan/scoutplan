class ApplicationController < ActionController::Base
  include Pundit

  def new_session_path(scope)
    new_user_session_path
  end
end
