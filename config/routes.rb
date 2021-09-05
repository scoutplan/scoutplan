Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :units do
    resources :events do
      member do
        post 'rsvp', to: 'events#rsvp'
      end
      member do
        get 'cancel', as: 'cancel'
      end
      member do
        get 'organize'
      end
    end
    resources :unit_memberships, path: 'members', as: 'members'
  end

  get 'r(/:id)', to: 'rsvp_tokens#login', as: 'rsvp_response'
  post 'rsvp_tokens/:id/resend', to: 'rsvp_tokens#resend', as: 'rsvp_token_resend'
end
