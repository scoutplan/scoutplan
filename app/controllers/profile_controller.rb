# frozen_string_literal: true

# edit user profile
class ProfileController < ApplicationController
  layout "global"

  def edit
    @user = current_user
  end

  def update
    redirect_to root_path, notice: t("profile.update_confirmation") if current_user.update!(user_params)
  end

  def edit_password
    @user = current_user
  end

  # rubocop:disable Style/GuardClause
  def update_password
    if current_user.update!(password_params)
      redirect_to edit_user_settings_path, notice: t("profile.update_password_confirmation")
    end
  end
  # rubocop:enable Style/GuardClause

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :nickname, :email, :phone)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
