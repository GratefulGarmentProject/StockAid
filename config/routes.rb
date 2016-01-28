Rails.application.routes.draw do
  resources :orders
  resources :shipments

  devise_for :users

  resources :orders
  resources :items, path: "/inventory"
  resources :contacts
  resources :organizations

  # TODO: Update this to correct path
  root to: "orders#index"
end
