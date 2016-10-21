Rails.application.routes.draw do
  root 'root#index'
  get '/root' => 'root#index'
  get '/feed' => 'root#feed', constraints: { format: :rss }

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
      get 'search'
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
  resources :feedbacks, only: [:index, :create]

  # devise
  devise_for :users
  resources :users, only: [:index, :show]

  # recognizer
  namespace :recognizer do
    root 'root#index', as: :root
    get  'about' => 'root#about'
    post 'api'   => 'root#api'
  end
end
