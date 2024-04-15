# frozen_string_literal: true

class UsersController < ApplicationController
  layout "unitless"
  include ApplicationHelper

  def change_password
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      redirect_to root_path, notice: "#{possessive_name_or_pronoun(@member, current_member).capitalize} password has been changed"
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
