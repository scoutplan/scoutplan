class ApplicationController < ActionController::Base
  include Pundit

  def current_user
  end
end
