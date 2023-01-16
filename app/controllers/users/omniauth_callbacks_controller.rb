# frozen_string_literal: true

module Users
  # override devise to allow for callback after sign in
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      user = User.from_omniauth(auth)
      if user.present?
        sign_out_all_scopes
        flash[:notice] = t("devise.omniauth_callbacks.success", kind: "Google")
        sign_in_and_redirect user, event: :authentication
      else
        flash[:alert] = t("devise.omniauth_callbacks.failure", kind: "Google", reason: "#{auth.info.email} is not authorized.")
        redirect_to new_user_session_path
      end
    end

    private

    def auth
      @auth ||= request.env["omniauth.auth"]
    end
  end
end
