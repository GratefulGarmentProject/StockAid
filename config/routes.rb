Rails.application.routes.draw do
  devise_for :users

  resources :categories
  resources :items, path: "/inventory" do
    get :edit_stock, on: :member
  end
  resources :orders do
    post :show_order_dialog
    post :new
  end
  resources :organizations
  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:create, :new, :show, :update]
  resources :users

  root to: "orders#index"
end
