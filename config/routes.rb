Rails.application.routes.draw do
  devise_for :users

  resources :categories, only: [:create]
  resources :contacts
  resources :items, path: "/inventory"
  resources :orders
  resources :shipments

  root to: "orders#index"
end
