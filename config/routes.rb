# frozen_string_literal: true

require 'sidekiq/web'

# rubocop disable Metrics/BlockLength
Rails.application.routes.draw do
  get 'news_items/index'
  get 'news_items/new'
  get 'news_items/create'
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
    resources :event_activities, as: 'activities', path: 'activities', only: %i[new create]
  end

  resources :event_activities, as: 'activities'

  get 'units/:id/settings', as: 'edit_unit_settings', to: 'unit_settings#edit'
  get 'units/:unit_id', to: 'events#index'
  get 'u/:id', to: redirect('units/%{id}'), status: 302
  get 'e/:id', to: redirect('/events/%{id}'), status: 302
  patch 'units/:id/settings', as: 'update_unit_settings', to: 'unit_settings#update'

  get 'units/:unit_id/messaging/drafts', to: 'messages#index', as: 'unit_newsletter_drafts', defaults: { mode: 'drafts' }
  get 'units/:unit_id/messaging/queued', to: 'messages#index', as: 'unit_newsletter_queued', defaults: { mode: 'queued' }
  get 'units/:unit_id/messaging/sent',   to: 'messages#index', as: 'unit_newsletter_sent',   defaults: { mode: 'sent'}

  resources :units do
    resources :plans, path: 'planner'
    resources :messages, path: 'messaging'
    resources :event_categories
    resources :news_items

    resources :events, only: %i[index new create] do
      collection do
        post 'bulk_publish'
      end
    end

    resources :unit_memberships, path: 'members', as: 'members', except: [:show] do
      collection do
        get  ':member_id',  to: 'unit_memberships#index'
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
  resources :news_items

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
