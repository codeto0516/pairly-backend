Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :users, only: [:index]
      resources :categories, only: [:index]

    end
  end
end
