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

    it 'reloads if login details are incorrect' do
      response = post(
        '/login',
        email: 'email_1@email.com',
        password: 'stro_password'
      )

      expect(response.status).to eq 200
      expect(response.body).to include('Invalid email and/or password. Please try again.')
    end
  end

  context 'GET /list_spaces' do
    it 'shows the list space page' do
      response = get('/list_spaces')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1> List a Space </h1>')
    end
  end

  context 'GET /list_space' do
    xit 'shows the all listed spaces' do
      response = get('/list_space')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Spaces</h1>')
    end
  end

  context 'GET /request_space' do
    xit 'shows the request_space' do
      response = get('/request_space')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1> Request Space </h1>')
    end
  end

  context 'GET /request_space' do
    xit 'shows the request_space' do
      response = get('/request_space')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1> Request Space </h1>')
    end
  end

  context 'POST /list_spaces' do
    it 'adds a new listing to the database with the users id' do
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
        expect(response.body).to include('Welcome, user 1')
        expect(response.body).to include('        <td>not so fancy space</td>')
        expect(response.body).to include('        <td>this is a not so fancy space</td>')

        expect(response.body).to include('<td>this is a fancy space</td>')
        expect(response.body).to include('<td>spartan space</td>')
      end
    end
  end

  describe 'GET /logout' do
    xit 'logs the user out' do
      login = get(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )

      dashboard = get('/dashboard')

      expect(dashboard.body).to include('<a class="button button-primary" href="/logout">Logout</a>')

      response get('/logout')

      expect(get('dashboard').status).to eq 302
      expect(get('dashboard').location).to match(%r{/login$})
    end
  end

  describe 'POST /spaces/id' do
    it 'returns a confirmation page after adding requesting a space' do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )

      response = post('/spaces/1', user_id: 1, space_id: 1, date: '01-02-2022', status: 'pending')
      expect(response.status).to eq 200
    end
  end
end
