class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :cognito_idp

  def cognito_idp
    @user = User.from_omniauth("omniauth.auth")

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Cognito") if is_navigational_format?
    else

    end
  end

  def failure
    redirect_to root_path
  end
end
