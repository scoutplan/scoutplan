Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :units do
    resources :events do
      member do
        post 'rsvp', to: 'events#rsvp'
      end
      member do
        get 'organize'
      end
    end
    resources :unit_memberships, path: 'members', as: 'members'
  end

  # resources :rsvp_tokens do
  #   member do
  #     post 'resend', to: 'rsvp_tokens#resend'
  #   end
  # end

  get 'r(/:id)', to: 'response#handle', as: 'rsvp_response'
end
