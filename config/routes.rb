Rails.application.routes.draw do

  #post
  post '/register', to: 'authentication#register'
  post '/login', to: 'authentication#login'
  post '/refresh', to: 'authentication#refresh'

  #get
  get 'user', to: 'users#user_details'

  #patch


  #delete


end