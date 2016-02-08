Rails.application.routes.draw do
  root 'root#index'

  namespace :collector do
    get '/' => 'root#index'
    get 'proxy' => 'proxy#index'

    resources :queries
    resources :labels do
      get 'faces'  => 'faces#labeled'
      get 'sample' => 'faces#sample'
      get 'all', on: :collection
    end
    resources :faces, only: [:index, :show, :destroy] do
      member do
        get 'image'
        post 'label'
      end
      collection do
        get 'random'
      end
    end
  end

  namespace :recognizer do
    get '/' => 'root#index'
    post '/api' => 'root#api'
  end
end
