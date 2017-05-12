Rails.application.routes.draw do
  devise_for :users
  resources :categories
  resources :donations, only: [:index, :new, :create]

  resources :items, path: "/inventory" do
    collection do
      get :deleted
    end

    member do
      get :restore
      get :edit_stock
    end
  end

  resources :orders, only: [:index, :new, :create, :edit, :update] do
    collection do
      get :rejected, :closed
    end
  end
  resources :organizations

  resources :reports, only: [] do
    collection do
      get :value_by_county
      get :value_by_donor
      get :total_inventory_value
      get :graphs
    end
  end

  resources :shipments
  resources :user_invitations, path: "/users/invitations", only: [:new, :create, :show, :update] do
    collection do
      get :open
      get :closed
    end
  end

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
