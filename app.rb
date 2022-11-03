require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require 'date'
require_relative 'lib/database_connection'
require_relative 'lib/user_repository'
require_relative 'lib/space_repository'
require_relative 'lib/utilities'
require_relative 'lib/request_repository'

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
    utilities = Utilities.new

    name = params[:name]
    email = params[:email]
    password = BCrypt::Password.create(params[:password])

    if utilities.validate_name(name) && utilities.validate_email(email)

      new_user = User.new
      new_user.name = name
      new_user.email = email
      new_user.password = password

      begin
        repo.create(new_user)
        return erb(:account_created)
      rescue StandardError
        @alert = 'Email address already in use'
        return erb(:signup)
      end
    else
      @alert = 'Please check your details'
      return erb(:signup)
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
    email = params[:email]
    password = params[:password]
    utils = Utilities.new
    repo = UserRepository.new

    user = repo.find_by_email(params[:email])

    if utils.validate_email(email) && !password.nil? && user != false
      if BCrypt::Password.new(user.password) == password
        session[:user_id] = user.id
        return redirect(:dashboard)
      else
        @alert = 'Invalid email and/or password. Please try again.'
        return erb(:login)
      end
    else
      @alert = 'Invalid email and/or password. Please try again.'
      return erb(:login)
    end
  end

  get '/spaces' do
    repo = SpaceRepository.new
    @spaces = repo.all
    return erb(:spaces)
  end

  get '/add_space' do
    if session[:user_id]
      return erb(:add_space)
    else
      return redirect('/login')
    end
  end

  post '/add_space' do
    repo = SpaceRepository.new
    utils = Utilities.new
    space = Space.new
    
    name = utils.sanitize(params[:name])
    description = utils.sanitize(params[:description])
    price_night = utils.sanitize(params[:price_night]).to_f
    
    if price_night.zero?
      @alert = 'Invalid inputs provided, please try again'
      return erb(:add_space)
    else
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      space.name = name
      space.description = description
      space.price_night = price_night
      space.start_date = start_date
      space.end_date = end_date
      space.user_id = session[:user_id]
      
      repo.create(space)
      return erb(:space_created)
    end
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

  post '/spaces/:id' do
    
    @space_id = params[:id]
    space_repo = SpaceRepository.new
    @space = space_repo.find_by_id(@space_id)
    request_repo = RequestRepository.new
    request = Request.new
    request.booked_by = session[:user_id]
    request.space_id = @space_id
    request.date = Date.parse(params[:date])
    request.status = 'pending'
    
    if request_repo.validate_request(request) == true
      begin
        request_repo.create(request)
        return erb(:booking_confirmed)
      rescue StandardError
        @alert = 'You cannot book a space for more than one night'
        return erb(:space_page)
      end
    else
      @alert = 'This space is not available on the selected date'
      return erb(:space_page)
    end
  end
end
