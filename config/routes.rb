Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    resources :reservations
  end

  resources :reservations

  resources :bikes do
    member do
      post :rent_bike
    end

    collection do
      post :search
    end
  end

  post 'authenticate', to: 'authentication#authenticate'
  post 'signup', to: 'authentication#signup'
  post 'reset_password', to: 'authentication#reset_password'
end
