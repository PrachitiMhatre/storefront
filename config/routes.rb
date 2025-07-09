Rails.application.routes.draw do
  get 'webhooks/stripe'
  devise_for :users
  # resources :products
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "products#index"

  get "/custom_sign_out", to: "users#custom_sign_out", as: :custom_sign_out
  resources :products, only: [:index, :show] do
    post :checkout, on: :member   # /products/:id/checkout
  end
  resources :subscriptions, only: [:new, :create]
  post '/webhooks/stripe', to: 'webhooks#stripe'
end
