# frozen_string_literal: true

module Users
  # override devise to allow for custom redirect after sign in
  class SessionsController < Devise::SessionsController
    before_action :find_unit

    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    def create
      if params[:user][:email].present? && params[:user][:password].present?
        super
      elsif params[:user][:email].present?
        send_session_email if resolve_user
      end
    end

    private

    def find_unit
      return unless (unit_id = cookies[:current_unit_id])

      @current_unit = Unit.find(unit_id)
    end

    def resolve_user
      @user = User.find_by(email: params[:user][:email])
      return false unless @user

      @user
    end

    def send_session_email
      UserMailer.with(user: @user, unit: @current_unit, target_path: target_path).session_email.deliver_later
    end

    def target_path
      params[:user_return_to] || root_path
    end
  end
end