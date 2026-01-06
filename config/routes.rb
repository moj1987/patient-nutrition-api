Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "patients/index"
  get "patients/:id", to: "patients#show"
  post "patients", to: "patients#create"
  patch "patients/:id", to: "patients#update"
  delete "patients/:id", to: "patients#destroy"

  resources :food_items, only: [ :index, :show, :create ]

  get "/patients/:patient_id/meals", to: "meals#index"
  post "/patients/:patient_id/meals", to: "meals#create"

  resources :meals, only: [ :show ] do
    resources :meal_food_items, only: [ :create ]
  end
end
