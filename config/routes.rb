# frozen_string_literal: true

require 'sidekiq/web'

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resources :events, only: %i[show edit update destroy] do
    member do
      get   'organize'
      patch 'create_or_update_rsvp'
      post  'cancel'
      post  'publish'
      post  'invite', to: 'event_rsvps#invite'
      get   'edit_rsvps'
    end

    resources :event_rsvps, as: 'rsvps', path: 'rsvps', only: %i[create]
    resources :event_activities, as: 'activities', path: 'activities', only: %i[new create]
  end

  resources :event_activities, as: 'activities'

  get 'units/:id/settings', as: 'edit_unit_settings', to: 'unit_settings#edit'
  patch 'units/:id/settings', as: 'update_unit_settings', to: 'unit_settings#update'

  get 'units/:unit_id/newsletter/drafts', to: 'news_items#index', as: 'unit_newsletter_drafts', defaults: { mode: 'drafts' }
  get 'units/:unit_id/newsletter/queued', to: 'news_items#index', as: 'unit_newsletter_queued', defaults: { mode: 'queued' }
  get 'units/:unit_id/newsletter/sent',   to: 'news_items#index', as: 'unit_newsletter_sent',   defaults: { mode: 'sent'}

  resources :units do
    resources :plans, path: 'planner'
    resources :event_categories
    resources :news_items, only: [ :index, :new, :create ]

    resources :events do
      collection do
        post 'bulk_publish'
      end
      get   'rsvp', as: 'edit_rsvps', to: 'events#edit_rsvps'
      patch 'rsvp', as: 'send_rsvps', to: 'events#create_or_update_rsvps'
      get   'organize', as: 'organize'
      get   'cancel'
      post  'cancel', to: 'events#perform_cancellation'
    end

    resources :unit_memberships, path: 'members', as: 'members' do
      collection do
        post 'bulk_update', to: 'unit_memberships#bulk_update'
        get  'import',      to: 'unit_memberships_import#new'
        post 'import',      to: 'unit_memberships_import#create'
      end
    end
  end # end units

  resources :unit_memberships, path: 'members', as: 'members', only: %i[show edit update destroy] do
    member do
      post 'invite'
      post 'send/:item', as: :send, to: 'unit_memberships#send_message'
    end
    resources :member_relationships, as: 'relationships', path: 'relationships', only: %i[new create destroy]
  end

  resources :member_relationships, as: 'relationships', path: 'relationships', only: %i[destroy]

  resources :news_items, only: [ :show, :edit, :update, :destroy ] do
    post 'enqueue', to: 'news_items#enqueue', as: 'enqueue'
    post 'dequeue', to: 'news_items#dequeue', as: 'dequeue'
  end

  get 'r(/:id)', to: 'rsvp_tokens#login', as: 'rsvp_response'
  post 'rsvp_tokens/:id/resend', to: 'rsvp_tokens#resend', as: 'rsvp_token_resend'

  constraints CanAccessFlipperUI do
    mount Sidekiq::Web => '/sidekiq'
    mount Flipper::UI.app(Flipper) => '/flipper'
    get 'a', to: 'admin#index'
  end
end
# rubocop:enable Metrics/BlockLength
