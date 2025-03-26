Rails.application.routes.draw do
  get "business/new"
  get "business/create"
  get "business/show"
  get "business/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "save_contact" => "pages#save_contact"
  get "sign_up" => "businesses#new"

  resources :businesses, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  resources :sessions, only: [ :new, :create ]
  delete "logout" => "sessions#destroy"

  root "pages#index"
  get "about" => "pages#about"
  get "privacy_policy" => "pages#privacy_policy"
  match "whatsapp_webhook" => "api#whatsapp_webhook", via: [:get, :post]
  get "contact" => "pages#contact"
  get "login" => "sessions#new"

  get "handle_click_and_redirect" => "api#handle_click_and_redirect"
end
