Rails.application.routes.draw do
  if !Rails.env.production? && Rails.application.config.action_mailer.delivery_method == :letter_opener_web
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users
  resources :bins, only: %i[index new create edit update destroy]
  resources :bin_locations, only: %i[index destroy]
  resources :categories, only: %i[new create edit update destroy]

  resources :donations, only: %i[index new create show edit update destroy] do
    collection do
      get :closed
      get :deleted
      get :migrate
      post :migrate, action: :save_migration
    end

    member do
      post :close
      patch :restore
      post :sync
      delete :destroy_closed
    end
  end

  resources :donors, only: %i[index new edit update create destroy] do
    collection do
      get :deleted
      get :export
      post :netsuite_import
    end

    member do
      patch :restore
    end
  end

  resources :help_links, only: %i[index create destroy] do
    member do
      post :toggle_visibility
      post :move_up
      post :move_down
    end
  end

  resources :items, path: "/inventory" do
    collection do
      get :deleted
    end

    member do
      patch :restore
      get :edit_stock
    end
  end

  resources :item_program_ratios, only: %i[index new create edit update destroy]

  resources :inventory_reconciliations, only: %i[index create show destroy] do
    resources :count_sheets, only: %i[index show update destroy] do
      collection do
        delete :unnecessary, action: :destroy_unnecessary
      end
    end

    collection do
      get :print_prep
      get :completed
    end

    member do
      get :deltas
      get :ignored_bins
      post :unignore_bin
      post :comment
      post :complete
    end
  end

  resources :net_suite_errors, only: %i[index show destroy]

  resources :orders, only: %i[index new create edit update] do
    collection do
      get :rejected, :closed, :canceled
    end

    member do
      post :sync
      get :survey_answers
    end
  end

  resources :organizations do
    collection do
      get :by_program
      get :deleted
      post :netsuite_import
    end

    member do
      patch :restore
    end
  end

  resources :programs, only: %i[index new create show update]

  resources :purchases, only: %i[index new create edit show update] do
    collection do
      get :closed, :canceled
    end

    member do
      post :sync
      patch :cancel
    end
  end

  resources :purchase_details, only: %i[create destroy]

  resources :purchase_shipments, only: %i[create destroy]

  resources :reports, only: [] do
    collection do
      get :donor_receipts
      get :graphs
      get :inventory_adjustments
      get :net_suite_export
      get :total_inventory_value
      get :inventory_flux
      get :value_by_county
      get :value_by_donor
      get :price_point_variance
    end
  end

  resources :revenue_streams, only: %i[index new create show update destroy] do
    collection do
      get :deleted
    end

    member do
      patch :restore
    end
  end

  resources :surveys, only: %i[index new create show update destroy] do
    member do
      get :demo
      post :demo, action: :submit_demo
    end
  end

  resources :survey_requests, only: %i[index new create show] do
    resources :answers, only: %i[show update], controller: "survey_request_answers", param: :org_request_id do
      member do
        get :view
        post :skip
      end
    end

    member do
      get :email
      get :export
      get :report
      post :email, action: :submit_email
    end
  end

  resources :tracking_details

  resources :user_invitations, path: "/users/invitations", only: %i[new create show update] do
    collection do
      get :open
      get :closed
    end
  end

  resources :users, only: %i[index edit update destroy] do
    collection do
      get :deleted
      get :export
    end

    member do
      post :reset_password
    end
  end

  resources :vendors, only: %i[index new edit update create destroy] do
    collection do
      get :deleted
      post :netsuite_import
    end

    member do
      patch :restore
    end
  end

  resource :backup, only: :show
  resource :exports, only: :show
  resource :integrations, only: :show

  resource :profiler, only: [] do
    post :toggle
  end

  get "/.well-known/acme-challenge/:id" => "letsencrypt#authenticate"

  root to: "orders#index"
end
