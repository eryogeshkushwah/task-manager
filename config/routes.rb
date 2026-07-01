Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  post "auth/register", to: "authentication#register"
  post "auth/login", to: "authentication#login"
  delete "auth/logout", to: "authentication#logout"

  # Projects REST API
  resources :projects

  # Tasks REST API with special state change routes
  resources :tasks do
    member do
      patch :complete
      patch :status, to: "tasks#change_status"
    end
  end

  # Dashboard API
  get "dashboard", to: "dashboard#show"
end
