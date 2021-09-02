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

  get 'r(/:id)', to: 'response#handle'
end
