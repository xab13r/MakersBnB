require 'spec_helper'
require 'rack/test'
require_relative '../../app'

def reset_tables
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe Application do
  include Rack::Test::Methods
  let(:app) { Application.new }

  before(:each) do
    reset_tables
  end

  describe 'GET /' do
    context 'if the user is not logged in' do
      it 'signup, login, and browse buttons' do
        response = get('/')
        expect(response.status).to eq 200
        expect(response.body).to include('<a class="button button-primary" href="/signup">Signup</a>')
        expect(response.body).to include('<a class="button button-primary" href="/login">Login</a>')
        expect(response.body).to include('<a class="button button-primary" href="/spaces">Browse</a>')
      end
    end

    context 'if the user is logged in' do
      it 'redirects to the dashboard' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )

        response = get('/')

        expect(response.status).to eq 302
        expect(response.location).to match(%r{/dashboard$})
      end
    end
  end

  context 'GET /signup' do
    it 'shows the sign up page' do
      response = get('/signup')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Sign Up</h1>')
      expect(response.body).to include('<a class="button button-primary" href="/spaces">Browse</a>')
      expect(response.body).to include('<a class="button button-primary" href="login">Login</a>')
    end
  end

  describe 'POST /signup' do
    it 'creates a new user' do
      response = post(
        '/signup',
        name: 'new user',
        email: 'new_user@email.com',
        password: 'strong password'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Your account has been created')
    end

    it 'fails if the email already exists on the database' do
      response = post(
        '/signup',
        name: 'new user',
        email: 'email_1@email.com',
        password: 'password1'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Email address already in use')
    end

    it 'fails if the name includes invalid characters' do
      response = post(
        '/signup',
        name: 'new_:user',
        email: 'email_1@email.com',
        password: 'password1'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Please check your details')
    end

    it 'fails if the email includes invalid characters' do
      response = post(
        '/signup',
        name: 'new user',
        email: 'email_email@@email.com',
        password: 'password1'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Please check your details')
    end
  end

  describe 'GET /login' do
    context 'if the user is not logged in' do
      it 'shows the login page' do
        response = get('/login')
        expect(response.status).to eq 200
        expect(response.body).to include('<h1>Login</h1>')
        expect(response.body).to include('<a class="button button-primary" href="/spaces">Browse</a>')
        expect(response.body).to include('<a class="button button-primary" href="/signup">Signup</a>')
      end
    end

    context 'if the user is already logged in' do
      it 'redirects to the dashboard' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )

        response = get('/login')

        expect(response.status).to eq 302
        expect(response.location).to match(%r{/dashboard$})
      end
    end
  end

  describe 'POST /login' do
    it 'logs the user in' do
      response = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )
      expect(response.status).to eq 302
      expect(response.location).to match(%r{/dashboard$})
    end

    it 'reloads with a message if the password is incorrect' do
      response = post(
        '/login',
        email: 'email_1@email.com',
        password: 'stro_password' # incorrect password
      )

      expect(response.status).to eq 200
      expect(response.body).to include('Invalid email and/or password. Please try again.')
    end
    
    it 'reloads with a message if the username is incorrect' do
      response = post(
        '/login',
        email: 'wrong-email@email.com',
        password: 'strong password' # incorrect password
      )
      
      expect(response.status).to eq 200
      expect(response.body).to include('Invalid email and/or password. Please try again.')
    end
  end

  describe 'GET /add_space' do
    context 'if the user is logged in' do
      it 'shows the form to list a new space' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )
        
        response = get('/add_space')
        
        expect(response.status).to eq 200
        expect(response.body).to include('<h1>List a Space</h1>')
      end
    end
    
    context 'if the user is not logged in' do
      it 'redirects to the login page' do
        response = get('/add_space')
        expect(response.status).to eq 302
        expect(response.location).to match(/\/login$/)
      end
    end
    
  end

  describe 'POST /list_spaces' do
    
    it "creates a new Space offered by the user" do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )
      
      response = post(
        '/add_space', 
        name: 'this is a new space', 
        description: 'a description for a nice new place', 
        price_night: 20.00,
        start_date: '12-12-2022', 
        end_date: '12-01-2023'
      )
      
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Space Created!</h1>')
      
      # It appears on the user dashboard
      expect(get('/dashboard').body).to include("this is a new space")
    end
    
    it "shows an error message if one of the fields has an invalid value" do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )
      
      response = post(
        '/add_space', 
        name: 'this is a new space', 
        description: 'a description for a nice new place', 
        price_night: 'invalid price',
        start_date: '12-12-2022', 
        end_date: '12-01-2023'
      )
      
      expect(response.status).to eq 200
      expect(response.body).to include('Invalid inputs provided, please try again')
    end
    
    xit 'adds a new listing to the database with the users id' do
      response = post('/list_spaces', name: 'test1', description: 'test1', price_night: 20.00,
                                      start_date: '01-02-2022', end_date: '02-02-2022', user_id: 1)
      expect(response.status).to eq 200
      expect(response.body).to include('<h1> Space Created! </h1>')
    end
  end

  context 'GET /spaces' do
    it 'shows all the spaces listed' do
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).to include('<tr>
              <td>fancy space</td>
              <td>this is a fancy space</td>
              <td>£100</td>
              <td><a href="/spaces/1">Book</a></td>
            </tr>')
    end

    it 'offers a signup and login button if user is not logged in' do
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).to include('<a class="button button-primary" href="/signup">Signup</a>')
      expect(response.body).to include('<a class="button button-primary" href="/login">Login</a>')
    end

    it 'offers a dashboard and logout button if user is logged in' do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )

      response = get('/spaces')
      expect(response.body).to include('<a class="button button-primary" href="/dashboard">Dashboard</a>')
      expect(response.body).to include('<a class="button button-primary" href="/logout">Logout</a>')
    end
  end

  describe 'GET /spaces/id' do
    context 'if the user is logged in' do
      it 'returns a page with details about a space' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )

        space_id = 3
        repo = SpaceRepository.new
        space = repo.find_by_id(space_id)

        response = get("/spaces/#{space_id}")

        expect(response.status).to eq 200
        expect(response.body).to include(space.name)
      end
    end

    context 'if the user is not logged in' do
      it 'redirects to the login page' do
        response = get('/spaces/1')

        expect(response.status).to eq 302
        expect(response.location).to match(%r{/login$})
      end
    end
  end

  describe 'GET /dashboard' do
    context 'if the user is not logged in' do
      it 'redirects to the login page' do
        response = get('/dashboard')
        expect(response.status).to eq 302
        expect(response.location).to match(%r{/login$})
      end
    end

    context 'if the user is logged in' do
      it 'returns the dashboard page' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )

        response = get('/dashboard')
        expect(response.status).to eq 200
        expect(response.body).to include('<a class="button button-primary" href="/logout">Logout</a>')
        expect(response.body).to include('<a class="button button-primary" href="/add_space">Add a Space</a>')
        expect(response.body).to include('Welcome, user 1')
        expect(response.body).to include('<td>not so fancy space</td>')
        expect(response.body).to include('<td>this is a not so fancy space</td>')

        expect(response.body).to include('<td>this is a fancy space</td>')
        expect(response.body).to include('<td>spartan space</td>')
      end
    end
  end

  describe 'GET /logout' do
    context "if the user is logged in" do
      it "logs the user out and redirects to the homepage" do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )
        # Check this page is reachable as the user is logged in
        dashboard = get('/dashboard')
        expect(dashboard.body).to include('<a class="button button-primary" href="/logout">Logout</a>')
        
        logout = get('/logout')
        
        # Verify it redirects to the homepage after logout
        expect(logout.location).to match(%r{/$})
        
        # Verify user has been logged out
        expect(get('dashboard').status).to eq 302
        expect(get('dashboard').location).to match(%r{/login$})
      end
    end
    
    context "if the user is not logged in" do
      it "redirects to the homepage" do
        logout = get('/logout')
        expect(logout.location).to match(%r{/$})
      end
    end
  end

  describe 'POST /spaces/id' do
    context "if booking is successful" do
      it 'returns a confirmation page' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )
        
        response = post(
          '/spaces/1', 
          user_id: 1, 
          space_id: 3, 
          date: '01-12-2022', 
          status: 'pending'
        )
        
        expect(response.status).to eq 200
        expect(response.body).to include('<h1>Booking confirmed</h1>')
        expect(response.body).to include('<h5>We hope you enjoy your stay!</h5>')
        expect(response.body).to include('<a class="button button-primary" href="/dashboard">Dashboard</a>')
    end
    
    # TODO: This test needs to be implemented
    it "shows the new booking on the user dashboard" do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )
      
      response = post(
        '/spaces/1', 
        user_id: 1, 
        space_id: 3, 
        date: '01-12-2022', 
        status: 'pending'
      )
      
      dashboard = get('/dashboard')
      expect(dashboard.body).to include("2022-12-01")
      expect(dashboard.body).to include("Pending")
    end
    
    xit 'shows the new booking on the host dashboard' do
      
    end
      
    end
  end
end
