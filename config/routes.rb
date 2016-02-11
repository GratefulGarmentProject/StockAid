Rails.application.routes.draw do
  devise_for :users

  resources :categories, only: [:create, :edit, :update, :destroy]
  resources :items, path: "/inventory"
  resources :orders do
    post :show_order_dialog
    post :new
  end
  resources :organizations
  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:new, :create, :index, :show, :update]
  resources :users

  root to: "orders#index"
end
