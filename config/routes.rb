Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :units do
    resources :events do
      member do
        get 'organize'
      end
    end
    resources :unit_memberships, path: 'members', as: 'members'
  end
end
