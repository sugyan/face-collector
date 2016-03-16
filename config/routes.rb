Rails.application.routes.draw do
  root 'root#index'
  get '/root' => 'root#index'

  resources :queries
  resources :labels do
    get 'faces' => 'faces#labeled'
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

  # devise
  devise_for :users

  # recognizer
  namespace :recognizer do
    root 'root#index'
    post 'api' => 'root#api'
  end
end
