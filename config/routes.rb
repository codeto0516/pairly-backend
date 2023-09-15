Rails.application.routes.draw do

  # 認証だけをするためのルーティング
  post 'api/v1/auth', to: 'application#auth'


  namespace :api do
    namespace :v1 do
      resources :users, only: [:show, :update] do
        collection do
          get 'me', to: 'users#me'
        end
      end
      resources :categories, param: :type_name

      resources :transactions do
        # GETリクエストで年と月を指定して取引データを取得
        get ':year/:month', on: :collection, action: 'get_transactions_for_specific_month'
      end

      resources :invitations
    end
  end
end
