Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:show] do
        collection do
          get 'me', to: 'users#me'
        end
      end
      resources :categories, param: :type_name
      resources :transactions
      resources :invitations
    end
  end
end
