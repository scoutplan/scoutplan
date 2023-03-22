# frozen_string_literal: true

module Users
  # override devise to allow for custom redirect after sign in
  class SessionsController < Devise::SessionsController
    before_action :find_unit

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    def create
      ap params[:remember_me]
      if params[:login_code].present?
        if (magic_link = MagicLink.find_by(login_code: params[:login_code]))
          sign_in(magic_link.user)
          magic_link.user.remember_me! if params[:remember_me] == "1"
          session[:via_magic_link] = true
          redirect_to magic_link.path
        else
          flash[:alert] = "Invalid login code"
          redirect_to root_path
        end
      elsif params[:user][:email].present? && params[:user][:password].present?
        self.resource = warden.authenticate!(auth_options)
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        yield resource if block_given?
        redirect_to params[:user_return_to] || root_path and return
      elsif params[:user][:email].present?
        send_session_email if resolve_user
      end
    end

    private

    def find_unit
      return unless (unit_id = cookies[:current_unit_id])

      begin
        @current_unit = Unit.find(unit_id)
      rescue ActiveRecord::RecordNotFound
        cookies[:current_unit_id] = nil
      end
    end

    def resolve_user
      @user = User.find_by(email: params[:user][:email])
      return false unless @user

      @current_unit ||= @user.units.first
      @user
    end

    def send_session_email
      member = @current_unit.membership_for(@user)
      magic_link = MagicLink.generate_link(member, target_path, ttl: 1.hour)
      UserMailer.with(magic_link: magic_link).session_email.deliver_later
    end

    def target_path
      params[:user_return_to] || root_path
    end
  end
end
