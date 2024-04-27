# frozen_string_literal: true

module Users
  # override devise to allow for custom redirect after sign in
  class SessionsController < Devise::SessionsController
    before_action :find_unit
    before_action :resolve_user

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create
      if params[:token].present?
        sign_in_via_magic_link
      elsif params.dig(:user, :password).present?
        sign_in_via_password
      elsif @user.nil? && cookies[:target_unit_id].present?
        redirect_to welcome_path
      elsif params.dig(:user, :email).present?
        send_session_email
      else
        redirect_to new
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def find_unit
      return unless (unit_id = cookies[:current_unit_id])

      begin
        @unit = Unit.find(unit_id)
      rescue ActiveRecord::RecordNotFound
        cookies[:current_unit_id] = nil
      end
    end

    def resolve_user
      return unless (email = params.dig(:user, :email))

      cookies[:email] = email
      @user = User.find_by(email: email)
      @unit ||= @user&.units&.first
      @user
    end

    def send_session_email
      return unless @unit

      member = @unit.membership_for(@user) || @user.unit_memberships.first
      redirect_to hello and return unless member

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

    def sign_in_via_password
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      session[:via_magic_link] = false
      redirect_to params[:user_return_to] || root_path and return
    end

    def target_path
      params[:user_return_to] || root_path
    end
  end
end
