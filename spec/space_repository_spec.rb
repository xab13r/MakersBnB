require 'space_repository'

def reset_tables
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

RSpec.describe SpaceRepository do
  before(:each) do
    reset_tables
  end

  describe '#space_from_record' do
    it 'returns a Space object from a SQL record' do
      record = {
        'id' => '1',
        'name' => 'space name',
        'description' => 'a new space description',
        'price_night' => '100.00',
        'start_date' => '2022-11-01',
        'end_date' => '2022-12-01',
        'user_id' => '1'
      }

      repo = SpaceRepository.new

      space = repo.space_from_record(record)

      expect(space.id).to eq 1
      expect(space.name).to eq 'space name'
      expect(space.description).to eq 'a new space description'
      expect(space.price_night).to eq 100.00
      expect(space.start_date).to eq Date.new(2022, 11, 0o1)
      expect(space.end_date).to eq Date.new(2022, 12, 0o1)
      expect(space.user_id).to eq 1
    end
  end

  describe '#all' do
    it 'returns an array of Space objects' do
      repo = SpaceRepository.new

      all_spaces = repo.all

      expect(all_spaces.length).to eq 6
      expect(all_spaces.first.id).to eq 1
      expect(all_spaces.first.name).to eq 'fancy space'
      expect(all_spaces.first.description).to eq 'this is a fancy space'
      expect(all_spaces.first.price_night).to eq 100.00
      expect(all_spaces.first.start_date).to eq Date.new(2022, 11, 1)
      expect(all_spaces.first.end_date).to eq Date.new(2022, 12, 1)
      expect(all_spaces.first.user_id).to eq 1

      expect(all_spaces.last.id).to eq 6
      expect(all_spaces.last.name).to eq 'spartan space'
      expect(all_spaces.last.description).to eq 'this is a spartan space'
      expect(all_spaces.last.price_night).to eq 20.0
      expect(all_spaces.last.start_date).to eq Date.new(2022, 12, 15)
      expect(all_spaces.last.end_date).to eq Date.new(2023, 1, 15)
      expect(all_spaces.last.user_id).to eq 3
    end
  end

  describe '#find_by_id' do
    it 'returns a Space object given its id' do
      repo = SpaceRepository.new
      id_to_find = 4
      space = repo.find_by_id(id_to_find)

      expect(space.id).to eq 4
      expect(space.name).to eq 'spartan space'
      expect(space.description).to eq 'this is a spartan space'
      expect(space.price_night).to eq 20.0
      expect(space.start_date).to eq Date.new(2022, 12, 15)
      expect(space.end_date).to eq Date.new(2023, 1, 15)
      expect(space.user_id).to eq 1
    end

    it 'returns false if there is no match' do
      repo = SpaceRepository.new
      id_to_find = 200
      expect(repo.find_by_id(id_to_find)).to eq false
    end
  end

  describe '#find_by_name' do
    context 'if the space name is unique' do
      it 'returns an array with one Space object given their username' do
        repo = SpaceRepository.new
        name_to_find = 'spartan space'

        spaces = repo.find_by_name(name_to_find)

        expect(spaces[0].id).to eq 4
        expect(spaces[0].name).to eq 'spartan space'
        expect(spaces[0].description).to eq 'this is a spartan space'
        expect(spaces[0].price_night).to eq 20.0
        expect(spaces[0].start_date).to eq Date.new(2022, 12, 15)
        expect(spaces[0].end_date).to eq Date.new(2023, 1, 15)
        expect(spaces[0].user_id).to eq 1
      end
    end

    context 'if the space name is not unique' do
      it 'returns an array of Space objects given their name' do
        repo = SpaceRepository.new
        name_to_find = 'spartan space'

        spaces = repo.find_by_name(name_to_find)

        expect(spaces.length).to eq 2
        expect(spaces.first.id).to eq 4
        expect(spaces.last.id).to eq 6
      end
    end

    it 'returns false if there is no match' do
      repo = SpaceRepository.new
      name_to_find = 'The fanciest space'

      expect(repo.find_by_name(name_to_find)).to eq false
    end
  end

  describe '#find_listed_by_user' do
    it 'returns an array of Space objects listed by a given user' do
      repo = SpaceRepository.new
      user_id = 1
      spaces = repo.find_listed_by_user(user_id)

      expect(spaces.length).to eq 3
      expect(spaces.first.id).to eq 1
      expect(spaces.last.id).to eq 5
    end

    it 'returns false if there is no match' do
      repo = SpaceRepository.new
      user_id = 100
      expect(repo.find_listed_by_user(user_id)).to eq false
    end
  end

  describe '#find_booked_by_user' do
    it 'returns an array of Space objects booked by a user' do
      repo = SpaceRepository.new
      user_id = 1
      spaces = repo.find_booked_by_user(user_id)

      expect(spaces.length).to eq 2
      expect(spaces.first.id).to eq 3
      expect(spaces.last.id).to eq 2
    end

    it 'returns false if there is no match' do
      repo = SpaceRepository.new
      user_id = 6
      expect(repo.find_booked_by_user(user_id)).to eq false
    end
  end

  describe '#find_spaces_by_user' do
    it 'returns an array of all Space objects who have been requested' do
      repo = SpaceRepository.new

      user_id = 1
      spaces = repo.find_spaces_by_user(user_id)

      expect(spaces.length).to eq 2
      expect(spaces.first.id).to eq 1
      expect(spaces.last.id).to eq 5
    end

    it 'returns false if there is no match' do
      repo = SpaceRepository.new

      user_id = 4
      spaces = repo.find_spaces_by_user(user_id)

      expect(spaces).to eq false
    end
  end

  describe '#create' do
    it 'add a space to the database' do
      space = Space.new
      space.name = 'a new space'
      space.description = 'a new space description'
      space.price_night = 150.00
      space.start_date = Date.parse('2023-01-01')
      space.end_date = Date.parse('2023-01-28')
      space.user_id = 4

      repo = SpaceRepository.new
      original_size = repo.all.length

      new_record_id = repo.create(space)

      expect(repo.all.length).to eq original_size + 1
      expect(repo.all).to include(
        have_attributes(
          name: 'a new space',
          description: 'a new space description',
          price_night: 150.0,
          user_id: 4,
          start_date: Date.new(2023, 0o1, 0o1),
          end_date: Date.new(2023, 0o1, 28)
        )
      )
    end
  end
end
