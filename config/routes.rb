Rails.application.routes.draw do
  # Public endpoints
  get "up" => "rails/health#show", as: :rails_health_check
  post "reset_db", to: "application#reset_db"

  # Authentication endpoints (public)
  namespace :auth do
    post "request-otp", to: "authentication#request_otp"
    post "verify-otp", to: "authentication#verify_otp"
  end

  # Protected endpoints (require authentication)
  resources :patients, except: [ :new, :edit ] do
    resources :meals, only: [ :index, :create ]
  end

  resources :food_items, only: [ :index, :show, :create ]
  resources :meals, only: [ :show ] do
    resources :meal_food_items, only: [ :create ]
  end

  get "/patients/:patient_id/meals", to: "meals#index"
  post "/patients/:patient_id/meals", to: "meals#create"

  resources :meals, only: [ :show ] do
    resources :meal_food_items, only: [ :create ]
  end
end
