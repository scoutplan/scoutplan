# frozen_string_literal: true

require "sidekiq/web"

# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/FormatStringToken
Rails.application.routes.draw do
  mount BetterMailerPreviews::Engine, at: "/better_mailer_previews" if Rails.env.development?
  root to: "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  %w[404 500].each do |code|
    get code, to: "errors#show", code: code
  end

  devise_for :users, path: "", controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions:           "users/sessions",
    registrations:      "users/registrations"
  }

  get "sms", to: "inbound_sms#receive"
  post "sms", to: "inbound_sms#receive"

  get "new_unit", to: redirect("/new_unit/start")
  get "new_unit/start", to: "new_unit#email"
  post "new_unit/confirm", to: "new_unit#confirm"
  get "new_unit/code", to: "new_unit#code"
  post "new_unit/check_code", to: "new_unit#check_code"
  get "new_unit/user_info", to: "new_unit#user_info"
  post "new_unit/save_user_info", to: "new_unit#save_user_info"
  get "new_unit/unit_info", to: "new_unit#unit_info"
  post "new_unit/save_unit_info", to: "new_unit#save_unit_info"
  get "new_unit/add_members", to: "new_unit#add_members"
  get "new_unit/add_member", to: "new_unit#add_member"
  post "new_unit/save_member", to: "new_unit#save_member"
  get "new_unit/import_member_list", to: "new_unit#import"
  post "new_unit/perform_import", to: "new_unit#perform_import"
  get "new_unit/communication_preferences", to: "new_unit#communication_preferences"
  post "new_unit/save_communication_preferences", to: "new_unit#save_communication_preferences"
  get "new_unit/done", to: "new_unit#done"

  resources :event_activities, as: "activities"
  resources :users, only: [:show, :become, :update]

  # get "units/:unit_id/settings", as: "edit_unit_settings", to: "unit_settings#edit"
  # patch "units/:unit_id/settings", as: "update_unit_settings", to: "unit_settings#update"

  get "units/*after", to: redirect("/u/%{after}")
  get "u/:unit_id/schedule/repeat_options/:starts_at", to: "events#repeat_options", as: "repeat_options"

  resources :payments, only: [:create]

  namespace :base, path: "/" do
    resources :events, only: [:show]
  end

  # begin units
  resources :units, path: "u", only: %i[show index update] do
    scope module: :units do
      resources :documents, path: "library" do
        collection do
          get "list"
          get "grid"
          get "tag/:tag", to: "documents#tag", as: "tag"
          post "bulk_update"
        end
      end
    end
    resources :messages, path: "messages" do
      resources :message_attachments, path: "attachments", as: "attachments", only: [:destroy]
      post "duplicate"
      post "unpin", as: "unpin"
      collection do
        get  "drafts"
        get  "sent"
        get  "outbox"
        post "recipients", as: "recipients"
        get  "addressables", as: "addressables"
        get  "select",     as: "select"
        post "commit",     as: "commit"
      end
    end

    resources :message_attachments
    resources :locations
    resources :packing_lists do
      resources :packing_list_items
    end
    resources :plans, path: "planner"
    resources :event_categories do
      get "remove", as: "remove"
    end
    resources :event_rsvps, only: [:destroy]
    resources :news_items do
      post "enqueue", to: "news_items#enqueue", as: "enqueue"
      post "dequeue", to: "news_items#dequeue", as: "dequeue"
    end

    get "my_rsvps", to: "events#my_rsvps", as: "my_rsvps"
    get "start",    to: "units#start",     as: "start"
    get "welcome",  to: "units#welcome",   as: "welcome"

    resources :payments, module: :settings do
      collection do
        post "onboard"
        get "refresh"
        get "return_from_onboarding"
      end
    end

    resources :events, path: "schedule" do
      resources :chat_messages, as: "discussion", path: "discussion"
      resources :family_rsvps, only: [:new, :create]
      resources :event_rsvps, as: "rsvps", path: "rsvps" do
        collection do
          get "popup"
          post "batch", to: "event_rsvps#create_batch"
          post "batch_member", to: "event_rsvps#create_batch_member" # kludge alert
        end
      end
      resources :event_rsvps
      resources :payments, module: :events
      resources :photos

      resources :event_attachments, path: "attachments", as: "attachments"
      resources :event_activities
      resources :event_organizers, as: "organizers", path: "organizers"
      resources :document_types
      resources :email_invitations, only: [:create]
      resources :event_reminders, path: "reminders", as: "reminders", only: [:create]
      resources :locations, module: :events
      member do
        get "dashboard", to: "event_dashboard#index", as: "dashboard"
        get "rsvp",      to: "events#show", as: "rsvp", defaults: { variation: "rsvp" }
      end
      collection do
        get "feed/:token", to: "calendar#index", as: "calendar_feed" # ICS link
        get "public",      to: "events#public", as: "public"
        get "signups",     to: "events#signups", as: "signups"
        get "list"
        get "paged_list"
        get "threeup"
        get "threeup/:year/:month", to: "events#threeup"
        # get "calendar", to: redirect { |path_params, _|
        #   "/units/#{path_params[:unit_id]}/schedule/calendar/#{Date.today.year}/#{Date.today.month}"
        # }, as: "calendar_redirect"
        # get "calendar"
        get "calendar", to: "events#calendar", as: "calendar_redirect"
        get "calendar/:year/:month", to: "events#calendar", as: "calendar"
        get "spreadsheet", to: "events#spreadsheet"
        post "bulk_publish"
      end
      # get   "rsvp", as: "edit_rsvps", to: "events#edit_rsvps"
      get   "cancel"
      get   "history"
      get   "add_to_calendar"
      post  "cancel", to: "events#perform_cancellation"
      patch "rsvp", as: "send_rsvps", to: "events#create_or_update_rsvps"

      constraints CanAccessFlipperUI do
        namespace :admin, module: :events do
          get   "/", to: "admin#index"
          post  "/remind", to: "admin#remind"
        end
      end
    end

    resources :photos

    post "search", to: "search#results", as: "search"
    get "search", to: "search#results"
    get "settings", to: "settings#index", as: "settings"
    get "settings/automated_messages", to: "settings#automated_messages", as: "automated_messages"
    get "settings/documents"
    get "settings/:category", to: "settings#edit", as: "setting"

    # redirect the old /events path. We can probably get rid of this
    # https://stackoverflow.com/questions/38509769/rails-routes-redirect-a-wild-card-route
    get "/events/*after", to: redirect("/u/%{unit_id}/schedule/%{after}")

    resources :unit_memberships

    resources :unit_memberships, path: "members", as: "members" do
      post "invite", to: "unit_memberships#invite", as: "invite"

      collection do
        post "bulk_update", to: "unit_memberships#bulk_update"
        get  "import",      to: "unit_memberships_import#new"
        post "import",      to: "unit_memberships_import#create"
      end

      resources :test_communications, module: :unit_memberships, only: %i[index create]
    end

    resources :wiki_pages, path: "pages" do
      get "history"
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

  ## Profile editing
  get   "user_settings/edit", to: "users#edit",   as: "edit_user_settings"
  patch "user_settings/save", to: "users#update", as: "update_user_settings"
  get   "settings/change_password", to: "users#change_password", as: "change_password"

  resources :profiles do
    get "change_password"
    patch "change_password", to: "profiles#perform_password_update"
  end

  get "profile/:id/payments", to: "profile#payments", as: "profile_payments"
  get "profile/:id/test", to: "profile#test", as: "test"

  # Member profile settings
  get "member_profile", to: "unit_membership_profiles#index", as: "member_profiles"
  get "member_profile/:unit_membership_id", to: "unit_membership_profiles#index", as: "member_profile"
  get "member_profile/:unit_membership_id/calendar", to: "unit_membership_profiles#calendar",
                                                     as: "member_calendar_profile"
  post "member_profile/:unit_membership_id", to: "unit_membership_profiles#update", as: "update_member_profile"

  resources :member_relationships, as: "relationships", path: "relationships", only: %i[destroy]
  resources :event_rsvps, except: [:index, :show, :edit, :update, :new]

  constraints CanAccessFlipperUI do
    mount Sidekiq::Web => "/sidekiq"
    mount Flipper::UI.app(Flipper) => "/flipper"
    mount Blazer::Engine, at: "blazer"
    get "a", to: "admin#index"
    namespace :admin do
      resources :users
      get "become/:user_id", to: "users#become"
    end
  end

  get ":token", to: "magic_links#resolve", as: "magic_link", constraints: { token: /[0-9a-f]{12}/ }
  get "link_expired", to: "magic_links#expired", as: "expired_magic_link"

  post "webhooks/mailgun/receive", to: "mailgun#receive"
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Style/FormatStringToken
