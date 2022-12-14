require 'date'
require_relative 'database_connection'
require_relative 'space'

class SpaceRepository
  def space_from_record(record)
    space = Space.new
    space.id = record['id'].to_i
    space.name = record['name']
    space.description = record['description']
    space.price_night = record['price_night'].to_f
    space.start_date = Date.parse(record['start_date'])
    space.end_date = Date.parse(record['end_date'])
    space.user_id = record['user_id'].to_i
    space.booked_date = record['date']
    space.status = record['status']
    space.booked_by = record['booked_by']
    space
  end

  def all
    sql_query = 'SELECT * FROM spaces;'
    sql_params = []
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    result_set.map { |record| space_from_record(record) }
  end

  def find_by_id(id)
    sql_query = 'SELECT * FROM spaces WHERE id = $1;'
    sql_params = [id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    space = result_set.map { |record| space_from_record(record) }

    return false if space.empty?

    space[0]
  end

  def find_by_name(name)
    sql_query = 'SELECT * FROM spaces WHERE name = $1;'
    sql_params = [name]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    spaces = result_set.map { |record| space_from_record(record) }

    return false if spaces.empty?

    spaces
  end

  def find_listed_by_user(user_id)
    sql_query = 'SELECT * FROM spaces WHERE user_id = $1;'
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    spaces = result_set.map { |record| space_from_record(record) }

    return false if spaces.empty?

    spaces
  end

  def find_booked_by_user(user_id)
    sql_query = 'SELECT spaces.id, spaces.name, spaces.description, spaces.price_night, spaces.start_date, spaces.end_date, spaces.user_id, bookings.booked_from, bookings.status FROM spaces
   JOIN bookings ON bookings.space_id = spaces.id
   JOIN users ON bookings.booked_by = users.id
   WHERE users.id = $1;'
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    spaces = result_set.map { |record| space_from_record(record) }

    return false if spaces.empty?

    spaces
  end

  def find_spaces_by_user(user_id)
    sql_query = 'SELECT spaces.id, spaces.name, spaces.description, spaces.price_night, spaces.start_date, spaces.end_date, spaces.user_id, bookings.booked_from, bookings.status, bookings.booked_by FROM spaces
    JOIN bookings ON bookings.space_id = spaces.id
    WHERE spaces.user_id = $1;'

    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    spaces = result_set.map { |record| space_from_record(record) }

    return false if spaces.empty?

    spaces
  end

  def create(space)
    sql_query = 'INSERT INTO spaces (name, description, price_night, start_date, end_date, user_id) VALUES ($1, $2, $3, $4, $5, $6);'
    sql_params = [space.name, space.description, space.price_night, space.start_date.iso8601, space.end_date.iso8601,
                  space.user_id]

    DatabaseConnection.exec_params(sql_query, sql_params)
  end
end
