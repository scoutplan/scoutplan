# frozen_string_literal: true

class ProfilesController < ApplicationController
  layout "unitless"

  before_action :find_profile

  def index
    authorize @profile
  end

  def edit
    authorize @profile
  end

  def alerts
    authorize @profile
  end

  def security
    authorize @profile
  end

  def display
    authorize @profile
  end

  def update
    authorize @profile
    if @member.update!(member_params)
      update_settings
      redirect_to root_path, notice: "Member settings have been updated"
    else
      render edit
    end
  end

  def payments
    @user = current_user
    @payments = Payment.where(unit_membership: @user.family.collect(&:id)).order(created_at: :desc)
  end

  def test; end

  def update_password
    authorize @profile
  end

  def perform_password_update
    if @member.update(member_params.merge(password_changed_at: Time.now))
      redirect_to root_path, notice: "Password updated"
    else
      render "security"
    end
  end

  private

  def find_profile
    @member = UnitMembership.find(params[:profile_id] || params[:id])
    @unit = @member.unit
    @current_member = @unit.membership_for(current_user)
    @profile = UnitMembershipProfile.new(@member)
  end

  def member_params
    params.require(:unit_membership).permit(
      :allow_youth_rsvps,
      :ical_suppress_declined,
      :roster_display_email, :roster_display_phone,
      user_attributes: [:id, :first_name, :last_name, :email, :phone, :password, :password_confirmation, :first_day_of_week]
    )
  end

  def setting_params
    params.require(:settings).permit(communication: [:via_email, :via_sms])
  end

  def update_settings
    return unless params[:settings].present?

    setting_params.each do |category, kvpairs|
      kvpairs.transform_keys(&:to_sym)
      @member.settings(category.to_sym).update!(kvpairs)
    end
  end
end
