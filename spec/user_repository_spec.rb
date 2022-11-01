require 'user_repository'

def reset_tables
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) do
    reset_tables
  end

  describe '#user_from_record' do
    it 'returns a User object from a SQL record' do
      record = {
        'id' => '1',
        'name' => 'name',
        'email' => 'email@email.com',
        'password' => 'encrypted password'
      }

      repo = UserRepository.new

      user = repo.user_from_record(record)

      expect(user.id).to eq 1
      expect(user.name).to eq 'name'
      expect(user.email).to eq 'email@email.com'
      expect(user.password).to eq 'encrypted password'
    end
  end

  describe '#all' do
    it 'returns an array of User objects' do
      repo = UserRepository.new

      all_users = repo.all

      expect(all_users.length).to eq 6
      expect(all_users.first.id).to eq 1
      expect(all_users.first.name).to eq 'user 1'
      expect(all_users.first.email).to eq 'email_1@email.com'
      expect(all_users.first.password).to eq '$2a$12$7mfDByVKXH/lhYEyw0WXr.mLZ5QP5XsdmruSM/YCKiUav2IGpgr32'

      expect(all_users.last.id).to eq 6
      expect(all_users.last.name).to eq 'user 5'
      expect(all_users.last.email).to eq 'email_6@email.com'
      expect(all_users.last.password).to eq '$2a$12$I7cIVdo4bVtL7r8Tgq0tr.ywyHZQsXZ1ZUI2MxpkZHCueKC5CAGSe'
    end
  end

  describe '#find_by_id' do
    it 'returns a User object given its id' do
      repo = UserRepository.new
      id_to_find = 2
      user = repo.find_by_id(id_to_find)

      expect(user.id).to eq 2
      expect(user.name).to eq 'user 2'
      expect(user.email).to eq 'email_2@email.com'
      expect(user.password).to eq '$2a$12$hUioakBqsrZba1ewCmc28uqEYkghNy8Mb37rl1baBEJWD3usufi4a'
    end

    it 'returns false if there is no match' do
      repo = UserRepository.new
      id_to_find = 200
      expect(repo.find_by_id(id_to_find)).to eq false
    end
  end

  describe '#find_by_name' do
    context 'if the username is unique' do
      it 'returns an array with one User object given their username' do
        repo = UserRepository.new
        name_to_find = 'user 1'

        users = repo.find_by_name(name_to_find)

        expect(users[0].id).to eq 1
        expect(users[0].name).to eq 'user 1'
        expect(users[0].email).to eq 'email_1@email.com'
      end
    end

    context 'if the username is not unique' do
      it 'returns an array of User objects given their username' do
        repo = UserRepository.new
        name_to_find = 'user 5'

        users = repo.find_by_name(name_to_find)

        expect(users.length).to eq 2
        expect(users.first.id).to eq 5
        expect(users.last.id).to eq 6
      end
    end

    it 'returns false if there is no match' do
      repo = UserRepository.new
      name_to_find = 'John Doe'

      expect(repo.find_by_name(name_to_find)).to eq false
    end
  end

  describe '#find_by_email' do
    it 'returns a User object given its email' do
      repo = UserRepository.new
      email_to_find = 'email_1@email.com'

      user = repo.find_by_email(email_to_find)

      expect(user.id).to eq 1
      expect(user.name).to eq 'user 1'
      expect(user.email).to eq 'email_1@email.com'
    end

    it 'returns false if there is no match' do
      repo = UserRepository.new
      email_to_find = 'email_1@email'

      expect(repo.find_by_email(email_to_find)).to eq false
    end
  end

  describe '#find_by_space' do
    it 'returns an array of User objects given a space id' do
      repo = UserRepository.new
      space_id = 2

      users = repo.find_by_space(space_id)

      expect(users.length).to eq 2
      expect(users.first.id).to eq 3
      expect(users.last.id).to eq 4
    end
  end

  describe '#create' do
    it 'add a user to the database' do
      user = User.new
      user.name = 'user 5'
      user.email = 'email_5@email.com'
      user.password = 'strong password'

      repo = UserRepository.new
      original_size = repo.all.length

      new_record_id = repo.create(user)

      expect(repo.all.length).to eq original_size + 1
      expect(repo.all).to include(
        have_attributes(
          name: 'user 5',
          email: 'email_5@email.com',
          password: 'strong password'
        )
      )
    end
  end
end
