require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products

  resource :cart, only: %i[show create]
  resolve('Cart') { [:cart] }
  post '/cart/add_item', to: 'carts#add_item'
  delete '/cart/:product_id', to: 'carts#destroy_item'

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'rails/health#show'
end
