# frozen_string_literal: true

require "sidekiq/web"

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root to: "home#index"

  %w[404 500].each do |code|
    get code, to: "errors#show", code: code
  end

  devise_for :users

  # resources :events, only: %i[show edit update destroy] do
  #   member do
  #     get   "organize"
  #     patch "create_or_update_rsvp"
  #     post  "cancel"
  #     post  "publish"
  #     post  "invite", to: "event_rsvps#invite"
  #     get   "edit_rsvps"
  #   end

  #   resources :event_rsvps, as: "rsvps", path: "rsvps", only: %i[create]
  #   resources :event_activities, as: "activities", path: "activities", only: %i[new create]
  # end

  resources :event_activities, as: "activities"
  resources :users

  get "units/:unit_id/settings", as: "edit_unit_settings", to: "unit_settings#edit"
  patch "units/:unit_id/settings", as: "update_unit_settings", to: "unit_settings#update"

  # begin units
  resources :units, only: %i[show index] do
    resources :messages
    resources :plans, path: "planner"
    resources :event_categories
    resources :event_rsvps, only: [:destroy]
    resources :news_items do
      post "enqueue", to: "news_items#enqueue", as: "enqueue"
      post "dequeue", to: "news_items#dequeue", as: "dequeue"
    end
    resources :news_items, path: "announcements", as: "announcements" do
      collection do
        get "drafts", to: "news_items#index", as: "drafts", defaults: { mode: "drafts" }
        get "queued", to: "news_items#index", as: "queued", defaults: { mode: "queued" }
        get "sent", to: "news_items#index", as: "sent", defaults: { mode: "sent" }
      end
      post "enqueue", to: "news_items#enqueue", as: "enqueue"
      post "dequeue", to: "news_items#dequeue", as: "dequeue"
    end

    resources :events, path: "schedule" do
      resources :event_rsvps, as: "rsvps", path: "rsvps", only: %i[create]
      resources :event_activities
      resources :event_organizers, as: "organizers", path: "organizers"
      resources :document_types
      collection do
        get  "feed/:token", to: "calendar#index", as: "calendar_feed" # ICS link
        get  "my_rsvps",    to: "events#index", defaults: { variation: "rsvps" }
        get  "list",        to: "events#index", defaults: { variation: "event_table" }, as: "list"
        get  "calendar", to: "events#index", defaults: { variation: "calendar" }
        get  "calendar/:year/:month", to: "events#index", defaults: { variation: "calendar" }, as: "targeted_calendar"
        get  "public", to: "events#public", as: "public"
        post "bulk_publish"
      end
      get   "rsvp", as: "edit_rsvps", to: "events#edit_rsvps"
      get   "rsvps"
      get   "cancel"
      get   "organize"
      post  "cancel", to: "events#perform_cancellation"
      patch "rsvp", as: "send_rsvps", to: "events#create_or_update_rsvps"
    end

    # https://stackoverflow.com/questions/38509769/rails-routes-redirect-a-wild-card-route
    get "/events/*after", to: redirect("/units/%{unit_id}/schedule/%{after}")

    resources :unit_memberships

    resources :unit_memberships, path: "members", as: "members" do
      post "invite", to: "unit_memberships#invite", as: "invite"

      collection do
        post "bulk_update", to: "unit_memberships#bulk_update"
        get  "import",      to: "unit_memberships_import#new"
        post "import",      to: "unit_memberships_import#create"
      end
    end
  end
  # end units

  # begin members
  resources :unit_memberships, path: "members", as: "members", only: %i[show edit update destroy] do
    member do
      post "invite"
      # post "send/:item", as: :send, to: "unit_memberships#send_message"
    end
    resources :member_relationships, as: "relationships", path: "relationships", only: %i[new create destroy]
  end
  # end members

  resources :event_rsvps do
    resources :documents
  end

  # Profile editing
  get   "profile/edit", to: "profile#edit",   as: "edit_profile"
  patch "profile/save", to: "profile#update", as: "update_profile"
  get   "profile/change_password", to: "profile#edit_password", as: "edit_password"
  patch "profile/save_password", to: "profile#update_password", as: "update_password"

  post "units/:unit_id/members/:member_id/test_communication/:message_type", to: "test_communications#create", as: "create_test_communication"

  resources :member_relationships, as: "relationships", path: "relationships", only: %i[destroy]
  resources :event_rsvps, except: [:index, :show, :edit, :update, :new]

  constraints CanAccessFlipperUI do
    mount Sidekiq::Web => "/sidekiq"
    mount Flipper::UI.app(Flipper) => "/flipper"
    mount Blazer::Engine, at: "blazer"
    get "a", to: "admin#index"
  end

  get ":token", to: "magic_links#resolve", as: "magic_link", constraints: { token: /[0-9a-f]{12}/ }
  get "link_expired", to: "magic_links#expired", as: "expired_magic_link"
end
# rubocop:enable Metrics/BlockLength
