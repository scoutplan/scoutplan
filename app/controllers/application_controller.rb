# frozen_string_literal: true

# base Controller class
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :process_query_string
  after_action  :clear_session_view

  def new_session_path(_scope)
    new_user_session_path
  end

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Request-Method"] = "*"
  end

  # if a ?view=NNNN querystring is present, stuff the value
  # into the session and then redirect to the base URL, thus
  # stripping the querystring off
  # DANGER: this might interfere with other querystrings in the future
  def process_query_string
    session[:view] ||= params[:view]
    redirect_to request.path if params[:view]
  end

  def clear_session_view
    session[:view] = nil
  end

  def page_title(*args)
    if args.is_a?(Array)
      @page_title = args
    elsif args[0].is_a?(String)
      @page_title = [args[0]]
    else
      @page_title = []
    end
  end

  # devise redirect after signout
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  def current_member
  end
end
