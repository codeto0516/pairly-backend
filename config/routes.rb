Rails.application.routes.draw do

  # 認証だけをするためのルーティング
  post 'api/v1/auth', to: 'api/v1/base#auth'

  namespace :api do
    namespace :v1 do
      resources :users, only: [:show, :update] do
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
