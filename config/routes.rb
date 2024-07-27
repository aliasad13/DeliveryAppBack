Rails.application.routes.draw do
  post '/register', to: 'authentication#register'
  post '/login', to: 'authentication#login'
  post '/refresh', to: 'authentication#refresh'
end