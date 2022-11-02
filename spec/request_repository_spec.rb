require './lib/request_repository'

def reset_tables
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

RSpec.describe RequestRepository do
  before(:each) do
    reset_tables
  end

  describe '#all' do
    it 'returns an array of request objects' do
      repo = RequestRepository.new

      all_requests = repo.all

      expect(all_requests.length).to eq 5
      expect(all_requests.first.user_id).to eq 1
      expect(all_requests.first.space_id).to eq 3
      expect(all_requests.first.date).to eq "2022-12-01" 
      expect(all_requests.first.status).to eq "booked"

      expect(all_requests.length).to eq 5
      expect(all_requests.last.user_id).to eq 1
      expect(all_requests.last.space_id).to eq 5
      expect(all_requests.last.date).to eq "2022-12-31" 
      expect(all_requests.last.status).to eq "booked"
    end
  end

describe '#create' do
    it 'add a new space request to the database' do
    request = Request.new
    request.user_id = 1
    request.space_id = 2
    request.date = '2022-11-10'
    request.status = 'pending'

    repo = RequestRepository.new
    original_size = repo.all.length

    new_record_id = repo.create(request)

    expect(repo.all.length).to eq original_size + 1
    expect(repo.all).to include(
        have_attributes(
        user_id: 1,
        space_id: 2,
        date: '2022-11-10',
        status: 'pending'))
    end
  end

  describe '#validate' do
    it 'checks if the space is already booked, returns true if not booked' do
    request = Request.new
    request.user_id = 1
    request.space_id = 2
    request.date = '2022-11-10'
    request.status = 'pending'

    repo = RequestRepository.new

    expect(repo.validate_request(request)).to eq true
    end
    it 'checks if the space is already booked, returns false if booked' do
        request = Request.new
        request.user_id = 1
        request.space_id = 3
        request.date = '2022-12-01'
        request.status = 'pending'
    
        repo = RequestRepository.new
    
        expect(repo.validate_request(request)).to eq false
        end


end

end