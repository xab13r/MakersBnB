require 'date'
require_relative 'database_connection'
require_relative './booking'

class BookingRepository
  def booking_from_record(record)
    booking = Booking.new
    booking.id = record['id'].to_i
    booking.booked_by = record['booked_by'].to_i
    booking.space_id = record['space_id'].to_i
    booking.listed_by = record['listed_by'].to_i
    booking.booked_from = Date.parse(record['booked_from'])
    booking.booked_to = Date.parse(record['booked_to'])
    booking.status = record['status']
    return booking
  end

  def all
    sql_query = 'SELECT * FROM bookings;'
    sql_params = []
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)
    bookings = result_set.map { |record| booking_from_record(record) }
    return bookings
  end

  def find_booking(booking_id)
    sql_query = 'SELECT * FROM bookings WHERE id = $1;'
    sql_params = [booking_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    booking = result_set.map { |record| booking_from_record(record) }

    return false if booking.empty?

    return booking[0]
  end

  def find_active_booking(user_id)
    sql_query = 'SELECT * FROM bookings WHERE booked_by = $1 AND (status <> \'cancelled\' OR status <> \'archived\');'
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    bookings = result_set.map { |record| booking_from_record(record) }

    return false if bookings.empty?

    return bookings
  end

  def find_active_listing(user_id)
    sql_query = 'SELECT * FROM bookings WHERE listed_by = $1 AND (status = \'pending\' OR status = \'confirmed\');'
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    listings = result_set.map { |record| booking_from_record(record) }

    return false if listings.empty?

    return listings
  end

  def find_booking_for_space(space_id)
    sql_query = 'SELECT * FROM bookings WHERE space_id = $1;'
    sql_params = [space_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    bookings = result_set.map { |record| booking_from_record(record) }

    return false if bookings.empty?

    return bookings
  end

  def create_booking(booking)
    sql_query = 'INSERT INTO bookings
      (booked_by, space_id, listed_by, booked_from, booked_to, status) VALUES
      ($1, $2, $3, $4, $5, $6);'
    sql_params = [
      booking.booked_by,
      booking.space_id,
      booking.listed_by,
      booking.booked_from,
      booking.booked_to,
      booking.status
    ]

    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def cancel_booking(booking_id)
    sql_query = 'UPDATE bookings SET status = \'cancelled\' WHERE id = $1;'
    sql_params = [booking_id]

    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def validate_booking(booking)
    sql_query = 'SELECT * FROM bookings
      WHERE space_id = $1
        AND booked_from = $2
        AND booked_to = $3
        AND status = $4;'
    sql_params = [
      booking.space_id,
      booking.booked_from,
      booking.booked_to,
      'confirmed'
    ]
    result = DatabaseConnection.exec_params(sql_query, sql_params)
    result.values.empty?
  end

  def confirm_booking(booking_id)
    sql_query = 'UPDATE bookings SET status = \'confirmed\' WHERE id = $1;'
    sql_params = [booking_id]

    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def archive_past_bookings
    today = Date.today.iso8601
    sql_query = "UPDATE bookings SET status = \'archived\' WHERE booked_to < \'#{today}\'"
    sql_params = []

    DatabaseConnection.exec_params(sql_query, sql_params)
  end

  def find_past_booking(user_id)
    sql_query = 'SELECT * FROM bookings WHERE booked_by = $1 AND status = \'archived\''
    sql_params = [user_id]
    result_set = DatabaseConnection.exec_params(sql_query, sql_params)

    past_bookings = result_set.map { |record| booking_from_record(record) }

    return false if past_bookings.empty?

    return past_bookings
  end
end
