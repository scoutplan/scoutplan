# frozen_string_literal: true

require 'sidekiq/web'

# rubocop disable Metrics/BlockLength
Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :events, only: %i[show edit update destroy] do
    member do
      get   'organize'
      patch 'create_or_update_rsvp'
      post  'cancel'
      post  'publish'
      post  'invite', to: 'event_rsvps#invite'
    end

    resources :event_rsvps, as: 'rsvps', path: 'rsvps', only: %i[create]
  end

  get 'units/:id/settings', as: 'edit_unit_settings', to: 'unit_settings#edit'
  get 'units/:unit_id', to: 'events#index'
  get 'u/:id', to: redirect('units/%{id}'), status: 302
  get 'e/:id', to: redirect('/events/%{id}'), status: 302
  patch 'units/:id/settings', as: 'update_unit_settings', to: 'unit_settings#update'

  resources :units do
    resources :events, only: %i[index new create] do
      collection do
        post 'bulk_publish'
      end
    end

    resources :event_categories

    resources :unit_memberships, path: 'members', as: 'members', only: %i[index new create] do
      collection do
        post 'bulk_update', to: 'unit_memberships#bulk_update'
        get  'import',      to: 'unit_memberships_import#new'
        post 'import',      to: 'unit_memberships_import#create'
      end
    end
  end

  resources :unit_memberships, path: 'members', as: 'members', only: %i[show edit update destroy] do
    member do
      post 'invite'
      post 'send/:item', as: :send, to: 'unit_memberships#send_message'
    end
    resources :member_relationships, as: 'relationships', path: 'relationships', only: %i[new create destroy]
  end

  resources :member_relationships, as: 'relationships', path: 'relationships', only: %i[destroy]

  get 'r(/:id)', to: 'rsvp_tokens#login', as: 'rsvp_response'
  post 'rsvp_tokens/:id/resend', to: 'rsvp_tokens#resend', as: 'rsvp_token_resend'

  constraints CanAccessFlipperUI do
    mount Sidekiq::Web => '/sidekiq'
    mount Flipper::UI.app(Flipper) => '/flipper'
    get 'a', to: 'admin#index'
  end

  get 'units/:unit_id/:slug', as: 'unit_home', to: 'events#index'
  get 'events/:id/:slug', as: 'event_home', to: 'events#show'
end
# rubocop enable Metrics/BlockLength
