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
end
