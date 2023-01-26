# frozen_string_literal: true

# The controller that handles magic link URLs, which
# look like https://scoutplan.org/1b3d56a, where 1b3d56a
# is a unique token. A MagicLink belongs_to a User (through
# its UnitMembership) and a path, so everything's present
# to log the user in and redirect them
#
class MagicLinksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_magic_link
  layout "public"

  # GET /:token
  def resolve
    raise ActionController::RoutingError, "Not Found" unless @magic_link.present?
    redirect_to @magic_link.path and return if user_signed_in?
    redirect_to expired_magic_link_path and return if @magic_link.expired?

    sign_in @magic_link.user
    session[:via_magic_link] = true
    # flash[:notice] = t("magic_links.login_success", name: current_user.full_name)
    redirect_to @magic_link.path
  end

  def resolve_login_code
  end

  def expired; end

  def current_member; end

  private

  def find_magic_link
    @magic_link = MagicLink.find_by(token: params[:token]) if params[:token].present?
    @magic_link = MagicLink.find_by(login_code: params[:login_code]) if params[:login_code].present?
  end
end
