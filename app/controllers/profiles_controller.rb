# frozen_string_literal: true

class ProfilesController < ApplicationController
  layout "unitless"

  before_action :find_profile

  def edit
    authorize @profile
  end

  def update
    redirect_to root_path, notice: t("profile.update_confirmation") if current_user.update!(user_params)
  end

  def edit_password
    @user = current_user
  end

  def payments
    @user = current_user
    @payments = Payment.where(unit_membership: @user.family.collect(&:id)).order(created_at: :desc)
  end

  def test; end

  # rubocop:disable Style/GuardClause
  def update_password
    if current_user.update!(password_params)
      redirect_to edit_user_settings_path, notice: t("profile.update_password_confirmation")
    end
  end
  # rubocop:enable Style/GuardClause

  private

  def find_profile
    @member = UnitMembership.find(params[:id])
    @unit = @member.unit
    @editing_member = @unit.membership_for(current_user)
    @profile = UnitMembershipProfile.new(@member)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :nickname, :email, :phone)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
