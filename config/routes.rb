Rails.application.routes.draw do
  resources :units do
    resources :events
  end
end
