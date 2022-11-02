require 'date'
require_relative 'database_connection'
require_relative 'request'

class RequestRepository
  def request_from_record(record)
    request = Request.new
    request.user_id = record['user_id'].to_i
    request.space_id = record['space_id'].to_i
    request.date = record['date']
    request.status = record['status']
    request
  end

  def all
    sql_query = 'SELECT * FROM users_spaces;'
    sql_params = []
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)
    result_set.map { |record| request_from_record(record) }
  end

  def create(request)
    sql_query = 'INSERT INTO users_spaces (user_id, space_id, date, status) VALUES ($1, $2, $3, $4);'
    sql_params = [request.user_id, request.space_id, request.date, request.status]
    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def validate_request(request)
    sql_query = 'SELECT * FROM users_spaces WHERE space_id = $1 AND date = $2 AND status = $3;'
    sql_params = [request.space_id, request.date, 'booked']
    result = DatabaseConnection.exec_params(sql_query, sql_params)
    result.values.empty?
  end
end
