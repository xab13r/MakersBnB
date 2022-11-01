require "spec_helper"
require "rack/test"
require_relative "../../app"


describe Application do
    include Rack::Test::Methods
    let(:app) { Application.new }

    context 'GET /' do
        it 'shows the home page' do
            response = get('/')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> Makers BnB Homepage </h1>')
            expect(response.body).to include('<a href="/sign_up"> Register</a>')
            expect(response.body).to include('<a href="/login"> Log in</a>')
        end
    end

    context 'GET /sign_up' do
        it 'shows the sign up page' do
            response = get('/sign_up')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> signup test </h1>')
        end
    end

    context 'POST /sign_up' do
        it 'creates a new data entry into the database' do
            response = post('/sign_up', name: 'test1', email: 'testemail1@hotmail.com', password: 'dan1')
            expect(response.status).to eq 200
            repo = UserRepository.new
            user = repo.find_by_email('testemail1@hotmail.com')
            expect(user.name).to eq 'test1'
            expect(user.email).to eq 'testemail1@hotmail.com'
        end

        it 'fails if the email already exists on the database' do
            response = post('/sign_up', name: 'test1', email: 'testemail1@hotmail.com', password: 'password1')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> Email already in use! </h1>')
        end    
    end

    context 'GET /login' do
        it 'shows the login page' do
            response = get('/login')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> login test </h1>')
        end
    end

    context 'POST /login' do
        it 'Logs the user in' do
            response = post('/login', email: 'email_4@email.com', password: 'strong password 3')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> User Dashboard </h1>')
        end
    end

    context 'GET /list_spaces' do
        it 'shows the list space page' do
            response = get('/list_spaces')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> List a Space </h1>')
        end
    end

    context 'POST /list_spaces' do
        it 'adds a new listing to the database with the users id' do
            response = post('/list_spaces', name: 'test1', description: 'test1', price_night: 20.00, start_date: '01-02-2022', end_date: '02-02-2022', user_id: 1)
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> Space Created! </h1>')
        end
    end
end