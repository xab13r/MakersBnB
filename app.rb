require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require 'date'
require_relative 'lib/database_connection'
require_relative 'lib/user_repository'
require_relative 'lib/space_repository'

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

  get '/' do
    return erb(:index)
  end

  get '/signup' do
    return erb(:signup)
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

  post '/login' do
    repo = UserRepository.new
    user = User.new
    user.email = params[:email]
    user.password = params[:password]
    check_user = repo.find_by_email(user.email)
    if BCrypt::Password.new(check_user.password) == user.password
      session[:user_id] = check_user.id
    return erb(:dashboard)
    end
  end
  
  get '/spaces' do
    repo = SpaceRepository.new
    @spaces = repo.all
    return erb(:spaces)
  end

  get '/list_spaces' do
    return erb(:list_spaces)
  end
  
  post '/list_spaces' do 
    repo = SpaceRepository.new
    space = Space.new
    space.name = params[:name]
    space.description = params[:description]
    space.price_night = params[:price_night]
    start_date = Date.parse(params[:start_date])
    space.start_date = start_date
    end_date = Date.parse(params[:end_date])
    space.end_date = end_date
    space.user_id = params[:user_id]
    repo.create(space)
    return erb(:space_created)
  
  end
  
  get '/spaces/:id' do
    if session[:user_id] == nil
      return redirect(:login)
    else
      space_id = params[:id]
      space_repo = SpaceRepository.new
      @space = space_repo.find_by_id(space_id)
      return erb(:space_page)
    end
  end
  
end
