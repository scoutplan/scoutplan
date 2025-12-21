# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def after_sign_in_path_for(resource)
      if @user.present?
        stored_location_for(resource) || root_path
      else
        new_user_session_path
      end
    end

    def create
      setup

      if params[:token].present?
        sign_in_via_magic_link
      elsif @user.present? && @password.present?
        sign_in_via_password
      elsif @user.present?
        send_session_email
      else
        super
      end
    end

    def setup
      @email = params.dig(:user, :email)
      @password = params.dig(:user, :password)
      @user = User.find_by(email: @email)
      unit_id = cookies[:current_unit_id]
      @unit = unit_id.present? ? Unit.find(unit_id) : @user&.units&.first
    end

    def send_session_email
      member = @unit.membership_for(@user) || @user.unit_memberships.first
      redirect_to hello and return unless member

      target_path = params[:user_return_to] || root_path
      magic_link = MagicLink.generate_link(member, target_path, 1.hour)
      UserMailer.with(magic_link: magic_link).session_email.deliver_later
    end

    def sign_in_via_magic_link
      magic_link = MagicLink.find_by(token: params[:token])
      sign_in(magic_link.user)
      magic_link.user.remember_me!
      session[:via_magic_link] = true
      redirect_to magic_link.path
    end

    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message! :notice, :signed_out if signed_out
      yield if block_given?
      redirect_to after_sign_out_path_for(resource_name), status: :see_other
    end

    # rubocop:disable Metrics/AbcSize
    def sign_in_via_password
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      session[:via_magic_link] = false
      redirect_to params[:user_return_to] || root_path and return
    end
    # rubocop:enable Metrics/AbcSize
  end
end
