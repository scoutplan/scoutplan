# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :events, only: %i[show edit update destroy] do
    member do
      get   'organize'
      patch 'rsvp'
      post  'cancel'
      post  'publish'
    end

  end

  resources :units do
    resources :events, only: %i[index new create] do
      collection do
        post 'bulk_publish'
      end
    end
    resources :unit_memberships, path: 'members', as: 'members', only: %i[index new create]
  end

  resources :unit_memberships, path: 'members', as: 'members', only: %i[show edit update destroy] do
  end

  get 'r(/:id)', to: 'rsvp_tokens#login', as: 'rsvp_response'
  post 'rsvp_tokens/:id/resend', to: 'rsvp_tokens#resend', as: 'rsvp_token_resend'

  mount Sidekiq::Web => '/sidekiq'
  constraints CanAccessFlipperUI do
    mount Flipper::UI.app(Flipper) => '/flipper'
  end
end
