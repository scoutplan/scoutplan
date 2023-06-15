module Admin
  class UsersController < ApplicationController
    layout "admin"

    def become
      return unless current_user.super_admin?
      sign_in(:user, User.find(params[:user_id]))
      redirect_to root_url # or user_root_url
    end    

    def index
    end

    def show
      @user = User.find(params[:id])
    end
  end
end