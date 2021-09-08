require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :events, only: [:show, :edit, :update, :destroy] do
    member do
      post 'rsvp'
      get  'cancel'
      get  'organize'
      post 'publish'
    end
  end

  resources :units do
    resources :events, only: [:index, :new, :create]
    resources :unit_memberships, path: 'members', as: 'members'
  end

  get 'r(/:id)', to: 'rsvp_tokens#login', as: 'rsvp_response'
  post 'rsvp_tokens/:id/resend', to: 'rsvp_tokens#resend', as: 'rsvp_token_resend'

  mount Sidekiq::Web => "/sidekiq"
end
