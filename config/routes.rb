Rails.application.routes.draw do
  devise_for :users

  resources :categories, only: [:create]
  resources :items, path: "/inventory"
  resources :orders
  resources :organizations
  resources :shipments
  resources :users

  root to: "orders#index"
end
