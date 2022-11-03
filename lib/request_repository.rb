require 'date'
require_relative 'database_connection'
require_relative 'request'
require 'date'

class RequestRepository
  def request_from_record(record)
    request = Request.new
    request.id = record['id'].to_i
    request.booked_by = record['booked_by'].to_i
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
    sql_query = 'INSERT INTO users_spaces (booked_by, space_id, date, status) VALUES ($1, $2, $3, $4);'
    sql_params = [request.booked_by, request.space_id, request.date, request.status]
    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def validate_request(request)
    sql_query = 'SELECT * FROM users_spaces WHERE space_id = $1 AND date = $2 AND status = $3;'
    sql_params = [request.space_id, request.date, 'booked']
    result = DatabaseConnection.exec_params(sql_query, sql_params)
    result.values.empty?
  end
  
  def cancel_request(booked_by, space_id)
    sql_query = 'UPDATE users_spaces SET status = \'cancelled\' WHERE booked_by = $1 AND space_id = $2'
    sql_params = [booked_by, space_id]
    DatabaseConnection.exec_params(sql_query, sql_params)
  end
  
  #def archive
  #  today = Date.today.iso8601
  #  
  #  completed_bookings_sql_query = "SELECT * FROM users_spaces WHERE date < \'#{today}\'"
  #  result_set = DatabaseConnection.exec_params(completed_bookings_sql_query, [])
  #  
  #  move_to_archive_sql_query = 'INSERT INTO archives (booked_by, space_id, date, status) 
  #                              VALUES
  #                              ($1, $2, $3, $4);'
  #  
  #  update_status_sql_query = "UPDATE users_spaces
  #  SET status = 'archived'
  #  FROM (
  #    SELECT *
  #    FROM users_spaces ) AS OtherTable
  #  WHERE
  #    users_spaces.date < \'#{today}\';"
  #  delete_from_join_sql_query = "DELETE FROM users_spaces WHERE status = \'archived\'"
  #  
  #  
  #  old_bookings = result_set.map { |record| request_from_record(record) }
  #  
  #  old_bookings.each do |booking|
  #    booking.status = 'archived'
  #    move_to_archive_params = [booking.booked_by, booking.space_id, booking.date, booking.status]
  #    DatabaseConnection.exec_params(move_to_archive_sql_query, move_to_archive_params)
  #  end
  #  
  #  DatabaseConnection.exec_params(update_status_sql_query, [])
  #  DatabaseConnection.exec_params(delete_from_join_sql_query, [])
  #end
  
end
