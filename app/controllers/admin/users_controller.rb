module Admin
  class UsersController < ApplicationController
    layout "admin"
    
    def index
    end

    def show
      @user = User.find(params[:id])
    end
  end
end