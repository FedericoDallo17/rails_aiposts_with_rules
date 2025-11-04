Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_for :users, path: "", path_names: {
        sign_in: "login",
        sign_out: "logout",
        registration: "signup"
      }, controllers: {
        registrations: "api/v1/registrations",
        sessions: "api/v1/sessions",
        passwords: "api/v1/passwords"
      }, defaults: { format: :json }

      # User routes
      resources :users, only: [ :show, :update, :destroy ] do
        member do
          get :followers
          get :following
          get :liked_posts
          get :commented_posts
        end
      end

      # Post routes
      resources :posts do
        member do
          post :like
          delete :unlike
          post :repost
          delete :unrepost
          get :reposts
        end
        resources :comments, only: [ :index, :create ]
      end

      # Comment routes
      resources :comments, only: [ :show, :update, :destroy ] do
        member do
          post :like
          delete :unlike
        end
      end

      # Follow routes
      post "follow/:id", to: "follows#create"
      delete "unfollow/:id", to: "follows#destroy"

      # Feed route
      get "feed", to: "feed#index"

      # Search routes
      get "search/users", to: "search#users"
      get "search/posts", to: "search#posts"

      # Notification routes
      resources :notifications, only: [ :index ] do
        member do
          patch :mark_as_read
          patch :mark_as_unread
        end
      end
    end
  end
end
