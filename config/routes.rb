Rails.application.routes.draw do
  get "business/new"
  get "business/create"
  get "business/show"
  get "business/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  
  # get "businesses" => "business#index"
  
  # get "businesses/:id" => "business#show"
  
  
  # get "sign_up" => "pages#sign_up"
  get "sign_up" => "businesses#new"

  resources :businesses, only: [:index, :show, :new, :create]

  
  root "pages#index"
  get "privacy_policy" => "pages#privacy_policy"
  match "whatsapp_webhook" => "api#whatsapp_webhook", via: [:get, :post]
end
