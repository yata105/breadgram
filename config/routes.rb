Rails.application.routes.draw do
  resources :posts
  get "home/index"

  root "posts#index"

  get "/settings", to: "users#settings", as: :settings
  
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users, param: :username
  resources :users, only: [:show]
  resources :likes, only: [:create, :destroy]
  resources :follows, only: [:create, :destroy]
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
