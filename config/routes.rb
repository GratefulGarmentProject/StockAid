Rails.application.routes.draw do
  devise_for :users
  resources :categories
  resources :donations, only: [:index, :new, :create]

  resources :items, path: "/inventory" do
    get :edit_stock, on: :member
  end

  resources :orders
  resources :organizations

  resources :reports, only: [] do
    collection do
      get :value_by_county
      get :value_by_donor
      get :total_inventory_value
    end
  end

  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:new, :create, :index, :show, :update]

  resources :users, only: [:index, :edit, :update, :destroy] do
    collection do
      get :deleted
    end

    member do
      post :reset_password
    end
  end

  resource :backup, only: :show
  resource :exports, only: :show

  resource :profiler, only: [] do
    post :toggle
  end

  get "/.well-known/acme-challenge/:id" => "letsencrypt#authenticate"

  root to: "orders#index"
end
