Rails.application.routes.draw do

  #post
  post '/register', to: 'authentication#register'
  post '/login', to: 'authentication#login'
  post '/refresh', to: 'authentication#refresh'

  #get
  get 'user', to: 'users#user_details'

  #patch
  resources :users, only: [] do
    member do
      patch 'update_names'
      post 'send_mail_verification_otp'
      patch 'update_email'
      patch 'update_password'
      patch :update_profile_picture
    end
  end

  resources :profile_pictures, only: [:create, :update, :destroy]
  #delete


end