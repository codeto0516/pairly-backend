Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :users, param: :uid
      resources :categories, only: [:index]
      resources :transactions
    end
  end
end
