require 'database_connection'
require 'user'

class UserRepository
  def user_from_record(record)
    user = User.new
    user.id = record['id'].to_i
    user.name = record['name']
    user.email = record['email']
    user.password = record['password']
    user
  end

  def all
    sql_query = 'SELECT * FROM users;'
    sql_params = []
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    result_set.map { |record| user_from_record(record) }
  end

  def find_by_id(id)
    sql_query = 'SELECT * FROM users WHERE id = $1;'
    sql_params = [id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    user = result_set.map { |record| user_from_record(record) }

    return false if user.empty?

    user[0]
  end

  def create(user)
    sql_query = 'INSERT INTO users (name, email, password) VALUES ($1, $2, $3);'
    sql_params = [user.name, user.email, user.password]

    DatabaseConnection.exec_params(sql_query, sql_params)
  end
end
