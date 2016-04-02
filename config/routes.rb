Rails.application.routes.draw do
  root 'root#index'
  get '/root' => 'root#index'

  resources :queries
  resources :labels do
    member do
      get 'faces'
      get 'faces_list'
      get 'inferences'
    end
    get 'all', on: :collection
  end
  resources :faces, only: [:index, :show, :destroy] do
    member do
      get 'image'
      post 'label'
    end
    collection do
      get 'labeled'
      get 'random'
      get 'collage'
      get 'tfrecords/:index_number' => 'faces#tfrecords'
    end
  end
  resources :inferences, only: [:index] do
    member do
      post 'accept'
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
