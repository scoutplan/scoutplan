# frozen_string_literal: true

module Users
  # override devise to allow for custom redirect after sign in
  class SessionsController < Devise::SessionsController
    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end
  end
end
