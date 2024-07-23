Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "games/game_status", to: "games#game_status"
  get "games/game_history", to: "games#game_history"
  get "games/leaderboard", to: "games#leaderboard"

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "pages#home"
  resources :games do
    resources :game_users, only: %i[create destroy]
    resources :rounds, only: %i[create]
  end
end
