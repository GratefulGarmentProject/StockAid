Rails.application.routes.draw do
  devise_for :users

  resources :categories
  resources :items, path: "/inventory" do
    get :edit_stock, on: :member
  end
  resources :orders
  resources :organizations
  resources :reports, only: :index
  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:new, :create, :index, :show, :update]

  resources :users, only: [:index, :edit, :update, :destroy] do
    collection do
      get :deleted
    end
  end

  get '/.well-known/acme-challenge/:id' => 'pages#letsencrypt'

  root to: "orders#index"
end
