Rails.application.routes.draw do
  root 'root#index'
  get '/root' => 'root#index'
  get '/feed' => 'root#feed'
end

# faces
Rails.application.routes.draw do
  resources :faces, only: [:index, :show, :destroy] do
    member do
      get 'image'
      post 'label'
    end
    collection do
      get 'search'
      get 'random'
      get 'collage'
      get 'tfrecords/:index_number' => 'faces#tfrecords'
    end
  end
end

# labels
Rails.application.routes.draw do
  resources :labels do
    member do
      get 'faces'
      get 'faces_list'
      get 'inferences'
    end
    get 'all', on: :collection
  end
end

# others
Rails.application.routes.draw do
  resources :queries
  resources :feedbacks, only: [:index, :create]

  resources :inferences, only: [:index] do
    member do
      post 'accept'
    end
  end
end

# recognizer
Rails.application.routes.draw do
  namespace :recognizer do
    root 'root#index', as: :root
    get  'about' => 'root#about'
    # APIs
    post 'image' => 'api#image'
    get  'faces' => 'api#faces'
  end
end

# devise, users
Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:index, :show, :create]
end
