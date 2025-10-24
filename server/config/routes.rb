Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      devise_for :users, path: "auth", path_names: {
        sign_in: "sign_in",
        sign_out: "sign_out",
        registration: "sign_up"
      }, controllers: {
        sessions: "api/v1/auth/sessions",
        registrations: "api/v1/auth/registrations",
        passwords: "api/v1/auth/passwords"
      }

      # Custom auth routes
      devise_scope :user do
        post "auth/forgot_password", to: "auth/passwords#create"
        put "auth/reset_password", to: "auth/passwords#update"
      end

      # Posts routes
      resources :posts do
        member do
          post :like
          delete :unlike
        end
        resources :comments, only: [:index, :create]
      end

      # Comments routes
      resources :comments, only: [:show, :update, :destroy]

      # Users routes
      resources :users, only: [:show, :index] do
        member do
          post :follow
          delete :unfollow
          get :followers
          get :following
        end
      end

      # Current user routes
      namespace :me do
        get "/", to: "users#show"
        put "/", to: "users#update"
        get :likes
        get :comments
        get :mentions
        get :tagged
      end

      # Feed route
      get :feed, to: "feed#index"

      # Search routes
      namespace :search do
        get :users
        get :posts
      end

      # Notifications routes
      resources :notifications, only: [:index, :show] do
        member do
          post :mark_as_read
          post :mark_as_unread
        end
      end
    end
  end
end
