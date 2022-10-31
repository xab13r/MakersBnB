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

      expect(all_users.length).to eq 4
      expect(all_users.first.id).to eq 1
      expect(all_users.first.name).to eq 'user 1'
      expect(all_users.first.email).to eq 'email_1@email.com'
      expect(all_users.first.password).to eq '$2a$12$7mfDByVKXH/lhYEyw0WXr.mLZ5QP5XsdmruSM/YCKiUav2IGpgr32'

      expect(all_users.last.id).to eq 4
      expect(all_users.last.name).to eq 'user 4'
      expect(all_users.last.email).to eq 'email_4@email.com'
      expect(all_users.last.password).to eq '$2a$12$I7cIVdo4bVtL7r8Tgq0tr.ywyHZQsXZ1ZUI2MxpkZHCueKC5CAGSe'
    end
  end
end
