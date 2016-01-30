Rails.application.routes.draw do
  devise_for :users

  resources :categories, only: [:create, :edit, :update, :destroy]
  resources :items, path: "/inventory"
  resources :orders
  resources :organizations
  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:create, :new, :save]
  resources :users

  root to: "orders#index"
end
