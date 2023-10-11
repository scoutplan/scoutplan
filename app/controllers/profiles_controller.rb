# frozen_string_literal: true

class ProfilesController < ApplicationController
  layout "unitless"

  before_action :find_profile

  def edit
    authorize @profile
  end

  def update
    if @member.update!(member_params)
      update_settings
      redirect_to root_path, notice: "Member settings have been updated"
    end
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

  def member_params
    params.require(:unit_membership).permit(user_attributes: [:id, :first_name, :last_name, :email, :phone])
  end

  def setting_params
    params.require(:settings).permit(communication: [:via_email, :via_sms], policy: [:youth_rsvps])
  end

  def update_settings
    setting_params.each do |category, kvpairs|
      kvpairs.transform_keys(&:to_sym)
      # kvpairs.delete(:youth_rsvps) unless @editing_member.adult?
      @member.settings(category.to_sym).update!(kvpairs)
    end
  end
end
