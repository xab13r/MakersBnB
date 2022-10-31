require "spec_helper"
require "rack/test"
require_relative "../../app"

describe Application do
    include Rack::Test::Methods
    let(:app) { Application.new }

    context 'GET /home' do
        xit 'shows the home page' do
            response = get('/home')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> Home Page </h1>')
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
        xit 'creates a new data entry into the database' do
            response = post('/sign_up', email_address: 'testemail1@msn.com', password: 'password1')
            expect(response.status).to eq 200
            expect(response.body).to include("Your account has been created")
            
        end
    end

    context 'GET /login' do
        it 'shows the login page' do
            response = get('/login')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> login test </h1>')
        end
    end

    context 'GET /dashboard' do
        xit 'shows the dashboard' do
            response = get('/dashboard')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> Dashboard </h1>')
        end
    end

    context 'GET /list_space' do
        xit 'shows the list_space' do
            response = get('/list_space')
            expect(response.status).to eq 200
            expect(response.body).to include('<h1> List Space </h1>')
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
end