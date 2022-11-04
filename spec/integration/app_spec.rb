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
        expect(response.location).to match(%r{/login$})
      end
    end
  end

  describe 'POST /add_space' do
    it 'creates a new Space offered by the user' do
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
      expect(response.body).to include('<h1>Your space has been listed</h1>')
      expect(response.body).to include('<a class="button button-primary" href="/dashboard">Dashboard</a>')

      # It appears on the user dashboard
      expect(get('/dashboard').body).to include('this is a new space')
    end

    it 'shows an error message if the price is invalid' do
      login = post(
        '/login',
        email: 'email_1@email.com',
        password: 'strong password'
      )

      response = post(
        '/add_space',
        name: 'this is a new space',
        description: 'a description for a nice new place',
        price_night: 'invalid price', # invalid price
        start_date: '12-12-2022',
        end_date: '12-01-2023'
      )

      expect(response.status).to eq 200
      expect(response.body).to include('Invalid inputs provided, please try again')
    end
  end

  context 'GET /spaces' do
    it 'shows all the spaces listed' do
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).to include('<td>fancy space</td>')
      expect(response.body).to include('<td>this is a fancy space</td>')
      expect(response.body).to include('<td>£100</td>')
      expect(response.body).to include('<td><a href="/spaces/1">Book</a></td>')
    end

    context 'if the space description is too long' do
      it 'will be truncated with an ellipsis' do
      end
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

      it 'will not allow an user to book their own spaces' do
        login = post(
          '/login',
          email: 'email_1@email.com',
          password: 'strong password'
        )

        space_id = 1
        repo = SpaceRepository.new
        space = repo.find_by_id(space_id)

        response = get("/spaces/#{space_id}")

        expect(response.status).to eq 200
        expect(response.body).to include(space.name)
        expect(response.body).to include('<p>This is one of your spaces</p>')
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
        expect(response.body).to include('not so fancy space</a>')
        expect(response.body).to include('<td>this is a not so fancy space</td>')

        expect(response.body).to include('<td>this is a fancy space</td>')
        expect(response.body).to include('<td>spartan space</td>')
      end
    end

    context 'for a new user' do
      it 'shows message about no listings/bookings/spaces' do
        new_user = post(
          '/signup',
          name: 'new user',
          email: 'new_email@email.com',
          password: 'password'
        )

        login = post(
          '/login',
          email: 'new_email@email.com',
          password: 'password'
        )

        response = get('/dashboard')

        expect(response.status).to eq 200
        expect(response.body).to include('No listings found')
        expect(response.body).to include('No bookings found')
        expect(response.body).to include('No spaces found')
      end
    end

    context 'if a user has no active bookings' do
      it 'shows a `no bookings found`message' do
        login = post(
          '/login',
          email: 'email_5@email.com',
          password: 'strong password 3'
        )

        response = get('/dashboard')

        expect(response.status).to eq 200
        expect(response.body).to include('No bookings found')
      end
    end

    context 'if a user has no active listings' do
      it 'shows a `no listings found`message' do
        new_user = post(
          '/signup',
          name: 'new user',
          email: 'new_email@email.com',
          password: 'password'
        )

        login = post(
          '/login',
          email: 'new_email@email.com',
          password: 'password'
        )

        create_space = post(
          '/add_space',
          name: 'this is a new space',
          description: 'a description for a nice new place',
          price_night: 20.00,
          start_date: '12-12-2022',
          end_date: '12-01-2023'
        )

        response = get('/dashboard')

        expect(response.status).to eq 200
        expect(response.body).to include('No bookings found')
        expect(response.body).to include('No listings found')
        expect(response.body).to include('this is a new space')
      end
    end
  end

  describe 'GET /logout' do
    context 'if the user is logged in' do
      it 'logs the user out and redirects to the homepage' do
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

    context 'if the user is not logged in' do
      it 'redirects to the homepage' do
        logout = get('/logout')
        expect(logout.location).to match(%r{/$})
      end
    end
  end

  describe 'POST /spaces/id' do
    context 'if booking is successful' do
      it 'returns a confirmation page' do
        login = post(
          '/login',
          email: 'email_2@email.com',
          password: 'strong password 1'
        )

        response = post(
          '/spaces/3',
          date: '02-12-2022',
          status: 'pending'
        )

        expect(response.status).to eq 200
        expect(response.body).to include('<h1>Your request has been sent to the host</h1>')
        expect(response.body).to include('<h5>We will let you know when it\'s approved</h5>')
        expect(response.body).to include('<a class="button button-primary" href="/dashboard">Dashboard</a>')
      end

      it 'shows the new booking on the user dashboard' do
        login = post(
          '/login',
          email: 'email_2@email.com',
          password: 'strong password 1'
        )

        response = post(
          '/spaces/3',
          date: '02-12-2022',
          status: 'pending'
        )

        dashboard = get('/dashboard')
        expect(dashboard.body).to include('2022-12-02')
        expect(dashboard.body).to include('pending')
      end

      it 'shows the new booking on the host dashboard' do
        login = post(
          '/login',
          email: 'email_2@email.com',
          password: 'strong password 1'
        )

        response = post(
          '/spaces/3',
          date: '02-12-2022',
          status: 'pending'
        )

        logout = get('/logout')

        login = post(
          '/login',
          email: 'email_3@email.com',
          password: 'strong password 2'
        )

        dashboard = get('/dashboard')
        expect(dashboard.body).to include('not so fancy space')
        expect(dashboard.body).to include('2022-12-02')
        expect(dashboard.body).to include('pending')
      end
    end

    context 'if the booking is unsuccesful' do
      it 'shows an error message and asks the user to try again' do
        login = post(
          '/login',
          email: 'email_5@email.com',
          password: 'strong password 3'
        )

        response = post(
          '/spaces/3',
          date: '01-12-2022',
          status: 'pending'
        )
        expect(response.status).to eq 200
        expect(response.body).to include('This space is not available on the selected date')
      end
    end
  end

  describe 'POST /cancel_booking/:id' do
    it 'changes the status of a confirmed booking to cancelled' do
      login = post(
        '/login',
        email: 'email_2@email.com',
        password: 'strong password 1'
      )

      dashboard = get('/dashboard')

      space_name = '<td>this is a fancier space</td>'

      expect(dashboard.body).to include('<td>fancier space</td>')
      expect(dashboard.body).to include('<td>this is a fancier space</td>')
      expect(dashboard.body).to include('<td>2022-11-01</td>')

      og_space_name_count = dashboard.body.scan(space_name).length

      cancel = post(
        '/cancel_booking/5'
      )

      expect(cancel.status).to eq 302

      dashboard = get('/dashboard')

      new_space_name_count = dashboard.body.scan(space_name).length

      expect(new_space_name_count).to eq og_space_name_count - 1
    end

    it "changes the status of a booked trip to cancelled" do 
        new_guest = post(
            '/signup',
            name: 'new guest',
            email: 'new_guest@email.com',
            password: 'password'
          )
    
          login = post(
            '/login',
            email: 'new_guest@email.com',
            password: 'password'
          )
    
          new_booking = post(
            '/spaces/6',
            date: '31-12-2022',
            status: 'pending'
          )

          dashboard = get('/dashboard')

          og_pending_count = dashboard.body.scan('pending').length
        
        expect(og_pending_count).to eq 1

        post (
            '/cancel_booking/8'
        )

        dashboard = get('/dashboard')

        expect(dashboard.body.scan('pending').length).to eq 0
        expect(dashboard.body.scan('cancelled').length).to eq 1



    end 
  end

  describe 'POST /confirm_booking/:id' do
    it 'changes the status from `pending` to `confirmed`' do
      login = post(
        '/login',
        email: 'email_2@email.com',
        password: 'strong password 1'
      )

      dashboard = get('/dashboard')

      og_pending_count = dashboard.body.scan('pending').length

      confirm = post(
        '/confirm_booking/3'
      )

      dashboard = get('/dashboard')

      new_pending_count = dashboard.body.scan('pending').length

      expect(new_pending_count).to eq og_pending_count - 1
    end
  end

  describe 'Full run test' do
    it 'tests a full run of the main functionalities' do
      # Create a new host
      new_host = post(
        '/signup',
        name: 'new host',
        email: 'new_host@email.com',
        password: 'password'
      )

      login = post(
        '/login',
        email: 'new_host@email.com',
        password: 'password'
      )

      # Create a new space
      new_space = post(
        '/add_space',
        name: 'new host new space',
        description: 'a description for a hosted place',
        price_night: 20.00,
        start_date: '12-12-2022',
        end_date: '12-01-2023'
      )

      logout = get('/logout')

      # Create a new guest
      new_guest = post(
        '/signup',
        name: 'new guest',
        email: 'new_guest@email.com',
        password: 'password'
      )

      login = post(
        '/login',
        email: 'new_guest@email.com',
        password: 'password'
      )

      # The guest book the new space
      new_booking = post(
        '/spaces/7',
        date: '31-12-2022',
        status: 'pending'
      )

      logout = get('/logout')

      # The host can see the request on their dashboard
      login = post(
        '/login',
        email: 'new_host@email.com',
        password: 'password'
      )

      dashboard = get('/dashboard')

      expect(dashboard.body).to include('pending')
      expect(dashboard.body).to include('2022-12-31')

      host_approves = post(
        '/confirm_booking/8'
      )

      dashboard = get('/dashboard')

      # The host can see the booking as confirmed
      expect(dashboard.body).to include('confirmed')
      expect(dashboard.body).to include('2022-12-31')

      logout = get('/logout')

      # The guest can see the booking as confirmed
      login = post(
        '/login',
        email: 'new_guest@email.com',
        password: 'password'
      )

      dashboard = get('/dashboard')

      # The guest can see the booking as confirmed
      expect(dashboard.body).to include('confirmed')
      expect(dashboard.body).to include('2022-12-31')
    end
  end
end
