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
    if session[:user_id].nil?
      return erb(:index)
    else
      return redirect('/dashboard')
    end
  end

  get '/signup' do
    return erb(:signup)
  end
 
  post '/signup' do 
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
    if session[:user_id].nil?
      return erb(:login)
    else
      return redirect('/dashboard')
    end
  end

  post '/login' do
    repo = UserRepository.new
    check_user = repo.find_by_email(params[:email])
    if BCrypt::Password.new(check_user.password) == params[:password]
      session[:user_id] = check_user.id
    return redirect(:dashboard)
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
    if session[:user_id].nil?
      return redirect(:login)
    else
      space_id = params[:id]
      space_repo = SpaceRepository.new
      @space = space_repo.find_by_id(space_id)
      return erb(:space_page)
    end
  end
  
  get '/dashboard' do
    if session[:user_id].nil?
      return redirect('/login')
    else
      user_id = session[:user_id]
      user_repo = UserRepository.new
      space_repo = SpaceRepository.new
      @user = user_repo.find_by_id(user_id)
      @spaces = space_repo.find_listed_by_user(user_id)
      @bookings = space_repo.find_booked_by_user(user_id)
      
      return erb(:dashboard)
    end
  end
  
  get '/logout' do
    if session[:user_id]
      session[:user_id] = nil
      return redirect('/')
    else
      return redirect('/')
    end
  end
  
end
