# frozen_string_literal: true

class UsersController < ApplicationController
  layout "unitless"
  
  def change_password
    @user = current_user
  end
end
