# frozen_string_literal: true

require "sidekiq/web"

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root to: "home#index"

  %w[404 500].each do |code|
    get code, to: "errors#show", code: code
  end

  devise_for :users

  resources :events, only: %i[show edit update destroy] do
    member do
      get   "organize"
      patch "create_or_update_rsvp"
      post  "cancel"
      post  "publish"
      post  "invite", to: "event_rsvps#invite"
      get   "edit_rsvps"
    end

    resources :event_rsvps, as: "rsvps", path: "rsvps", only: %i[create]
    resources :event_activities, as: "activities", path: "activities", only: %i[new create]
  end

  resources :event_activities, as: "activities"

  get "units/:id/settings", as: "edit_unit_settings", to: "unit_settings#edit"
  patch "units/:id/settings", as: "update_unit_settings", to: "unit_settings#update"

  get "units/:unit_id/newsletter/drafts", to: "news_items#index", as: "unit_newsletter_drafts", defaults: { mode: "drafts" }
  get "units/:unit_id/newsletter/queued", to: "news_items#index", as: "unit_newsletter_queued", defaults: { mode: "queued" }
  get "units/:unit_id/newsletter/sent",   to: "news_items#index", as: "unit_newsletter_sent",   defaults: { mode: "sent"}

  # begin units
  resources :units, only: [:show] do
    resources :plans, path: "planner"
    resources :event_categories
    resources :news_items, only: %i[index new create]

    resources :events do
      collection do
        get "my_rsvps", to: "events#index", defaults: { mode: "rsvps" }
        post "bulk_publish"
      end
      get   "rsvp", as: "edit_rsvps", to: "events#edit_rsvps"
      patch "rsvp", as: "send_rsvps", to: "events#create_or_update_rsvps"
      get   "organize", as: "organize"
      get   "cancel"
      post  "cancel", to: "events#perform_cancellation"
    end

    resources :unit_memberships, path: "members", as: "members" do
      collection do
        post "bulk_update", to: "unit_memberships#bulk_update"
        get  "import",      to: "unit_memberships_import#new"
        post "import",      to: "unit_memberships_import#create"
      end
    end
  end
  # end units

  resources :member_relationships, as: "relationships", path: "relationships", only: %i[destroy]

  resources :news_items, only: %i[show edit update destroy] do
    post "enqueue", to: "news_items#enqueue", as: "enqueue"
    post "dequeue", to: "news_items#dequeue", as: "dequeue"
  end

  constraints CanAccessFlipperUI do
    mount Sidekiq::Web => "/sidekiq"
    mount Flipper::UI.app(Flipper) => "/flipper"
    get "a", to: "admin#index"
  end

  get ":token", to: "magic_links#resolve", as: "magic_link"
end
# rubocop:enable Metrics/BlockLength
