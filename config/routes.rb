Rails.application.routes.draw do
  mount API::Base => "/"
  root "main#index"
  get "/invite" => "main#invite"

  get "/payment" => "main#payment"

  get "/admin" => "admin/login#new"
  post "/admin" => "admin/login#login"
  delete "/admin/logout" => "admin/login#logout"
  get "/admin/dashboard" => "admin/dashboard#index"
  namespace :admin do
    resources :users
    resources :app_banners
    resources :bid_offers
    resources :bid_plan_categories
    resources :bid_plans
    resources :user_bids
    resources :closed_bids
    resources :transaction_histories
  end
end
