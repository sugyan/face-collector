Rails.application.routes.draw do
  root 'root#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  namespace :collector do
    get '/' => 'root#index'
    get 'proxy' => 'root#proxy'

    resources :queries
    resources :labels do
      get 'faces'  => 'faces#labeled'
      get 'all', on: :collection
    end
    resources :faces, only: [:index, :show] do
      member do
        get 'image'
        post 'label'
      end
      collection do
        get 'random'
        get 'tfrecords/:index_number' => 'faces#tfrecords'
      end
    end
  end

  namespace :recognizer do
    get '/' => 'root#index'
    post '/api' => 'root#api'
  end
end
