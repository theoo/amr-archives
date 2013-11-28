AmrArchives::Application.routes.draw do

  devise_for :users
  resources :users
  resources :performances do

    member do
      get :remote_performance
      post :remote_performance
    end

    collection do
      get :set_search_mode, :list, :remote_catalog
      post :list, :remote_catalog
    end

  end

  resources :artists, :except => [:new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :instruments, :except => [:show, :new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :locations, :except => [:show, :new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :bands, :except => [:new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :medias, :except => [:show, :new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :genres, :except => [:show, :new, :create] do
    collection do
      post :list, :search
    end
  end

  resources :events, :except => [:new, :create] do
    collection do
      post :list, :search
    end
  end

  root "performances#index"

  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

end
