# frozen_string_literal: true

# The controller that handles magic link URLs, which
# look like https://scoutplan.org/1b3d56a, where 1b3d56a
# is a unique token. A MagicLink contains a User (through
# its UnitMembership) and a path, so everything's present
# to log the user in and redirect them
#
class MagicLinksController < ApplicationController
  before_action :find_magic_link

  # GET /:token
  def resolve(*args)
    puts args
    redirect_to root_path unless @magic_link

    sign_in @magic_link.user
    session[:via_magic_link] = true
    flash[:notice] = t("magic_links.login_success", name: current_user.full_name)
    redirect_to @magic_link.path
  end

  private

  def find_magic_link
    token = params[:token]
    @magic_link = MagicLink.find_by(token: token)
  end
end
