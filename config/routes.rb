Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :users
      resources :categories, param: :type_name
      resources :transactions
    end
  end
end
