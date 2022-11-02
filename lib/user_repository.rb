require_relative 'database_connection'
require_relative 'user'

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

  def find_by_name(name)
    sql_query = 'SELECT * FROM users WHERE name = $1;'
    sql_params = [name]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    users = result_set.map { |record| user_from_record(record) }

    return false if users.empty?

    users
  end

  def find_by_email(email)
    sql_query = 'SELECT * FROM users WHERE email = $1;'
    sql_params = [email]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    user = result_set.map { |record| user_from_record(record) }

    return false if user.empty?

    user[0]
  end

  def find_by_space(space_id)
    sql_query = 'SELECT users.id, users.name, users.email, users.password FROM users
    JOIN users_spaces ON users_spaces.user_id = users.id
    JOIN spaces ON users_spaces.space_id = spaces.id
    WHERE spaces.id = $1;'
    sql_params = [space_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    user = result_set.map { |record| user_from_record(record) }

    return false if user.empty?

    user
  end

  def create(user)
    if find_by_email(user.email) == false
      sql_query = 'INSERT INTO users (name, email, password) VALUES ($1, $2, $3);'
      sql_params = [user.name, user.email, user.password]

      DatabaseConnection.exec_params(sql_query, sql_params)
    else
      raise 'Email address already in use'
    end
  end
end
