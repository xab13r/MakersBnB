require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'lib/database_connection'
require_relative 'lib/user_repository'

ENV['ENV'] = 'test'
DatabaseConnection.connect

class Application < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/user_repository'
    enable :sessions
  end

  get '/sign_up' do
    return erb(:sign_up)
  end
 

  post '/sign_up' do 
    repo = UserRepository.new
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.password = BCrypt::Password.create(params[:password])
    
    if repo.find_by_email(user.email) == false
    repo.create(user)
      return erb(:account_creation)   
    else
    return erb(:email_invalid)
      
  end
end

  get '/login' do
    return erb(:login)
  end
<<<<<<< HEAD

  post '/login' do
    repo = UserRepository.new
    user = User.new
    user.email = params[:email]
    user.password = params[:password]
    check_user = repo.find_by_email(user.email)
    if BCrypt::Password.new(check_user.password) == user.password
    return erb(:logged_in)
    end
  end

  

end
=======
end
>>>>>>> main
