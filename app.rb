require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'lib/database_connection'

ENV['ENV'] = 'test'
DatabaseConnection.connect

class Application < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
  end
<<<<<<< HEAD
end
=======

  get '/sign_up' do
    return erb(:sign_up)
  end
  post '/sign_up' do
  end

  post '/sign_up' do 
    repo = UserRepository.new
    @user = User.new
    # @account.username = params[:username]
    @user.password = params[:password]
    @user.email = params[:email]
    repo.create(@user) 
    return erb(:account_creation) 
  end

  get '/login' do
    return erb(:login)
  end
end
>>>>>>> main
