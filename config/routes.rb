Rails.application.routes.draw do
  controller :sessions do
    get 'auth/auth0/callback' => :callback
    get 'auth/failure' => :failure
    get 'logout' => :destroy
  end

  root to: 'book#show'

  namespace :api do
    resources :guides, only: [:create]
    resources :topics, only: [:create]
    resources :books, only: [:create]
  end

  resources :book, only: [:show]
  resources :chapters, only: [:show]

  # All users
  resources :exercises, only: [:show, :index] do
    # Current user
    resources :solutions, controller: 'exercise_solutions', only: :create
    resources :queries, controller: 'exercise_query', only: :create
  end

  # All users
  resources :guides, only: [:show, :index]
  resources :lessons, only: [:show]
  resources :complements, only: [:show]
  resources :exams, only: [:show] #FIXME

  # All users
  resources :users, only: [:show, :index]

  # Guide route
  get '/guides/:organization/:repository' => 'guides#show_by_slug', as: :guide_by_slug
end
