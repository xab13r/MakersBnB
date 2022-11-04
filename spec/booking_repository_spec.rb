require 'booking_repository'

def reset_tables
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

RSpec.describe BookingRepository do
  before(:each) do
    reset_tables
  end

  describe '#booking_from_record' do
    it 'creates a Booking object from a SQL record' do
      record = {
        'id' => '1',
        'booked_by' => '1',
        'space_id' => '3',
        'listed_by' => '3',
        'booked_from' => '2022-12-01',
        'booked_to' => '2022-12-01',
        'status' => 'pending'
      }

      repo = BookingRepository.new

      booking = repo.booking_from_record(record)

      expect(booking.id).to eq 1
      expect(booking.booked_by).to eq 1
      expect(booking.space_id).to eq 3
      expect(booking.listed_by).to eq 3
      expect(booking.booked_from).to eq Date.parse('2022-12-01')
      expect(booking.booked_to).to eq Date.parse('2022-12-01')
      expect(booking.status).to eq 'pending'
    end
  end

  describe '#all' do
    it 'returns an array with all Booking objects from the table' do
      repo = BookingRepository.new
      bookings = repo.all

      expect(bookings.length).to eq 7
      expect(bookings.first.id).to eq 1
      expect(bookings.first.booked_by).to eq 1
      expect(bookings.first.space_id).to eq 3
      expect(bookings.first.listed_by).to eq 3
      expect(bookings.first.booked_from).to eq Date.new(2022, 12, 1)
      expect(bookings.first.booked_to).to eq Date.new(2022, 12, 1)
      expect(bookings.first.status).to eq 'confirmed'
    end
  end

  describe '#find_booking' do
    it 'returns a Booking object given its id' do
      id_to_find = 1
      repo = BookingRepository.new

      booking = repo.find_booking(id_to_find)

      expect(booking.id).to eq 1
      expect(booking.booked_by).to eq 1
      expect(booking.space_id).to eq 3
      expect(booking.listed_by).to eq 3
      expect(booking.booked_from).to eq Date.parse('2022-12-01')
      expect(booking.booked_to).to eq Date.parse('2022-12-01')
      expect(booking.status).to eq 'confirmed'
    end

    it 'returns false if there is no match' do
      id_to_find = 200
      repo = BookingRepository.new

      booking = repo.find_booking(id_to_find)
      expect(booking).to eq false
    end
  end

  describe '#find_active_booking' do
    it 'returns all future bookings for a user' do
      booked_by = 1

      repo = BookingRepository.new

      bookings = repo.find_active_booking(booked_by)

      expect(bookings.length).to eq 2
      expect(bookings.last.id).to eq 5
      expect(bookings.last.booked_by).to eq 1
      expect(bookings.last.space_id).to eq 2
      expect(bookings.last.listed_by).to eq 2
      expect(bookings.last.booked_from).to eq Date.new(2022, 11, 1)
      expect(bookings.last.booked_to).to eq Date.new(2022, 11, 1)
      expect(bookings.last.status).to eq 'confirmed'
    end

    it 'returns false if there is no match' do
      booked_by = 5

      repo = BookingRepository.new

      bookings = repo.find_active_booking(booked_by)
      expect(bookings).to eq false
    end
  end

  describe '#find_active_listing' do
    it 'returns all active listing for a user' do
      listed_by = 2

      repo = BookingRepository.new

      listings = repo.find_active_listing(listed_by)

      expect(listings.length).to eq 3
      expect(listings.last.id).to eq 5
      expect(listings.last.booked_by).to eq 1
      expect(listings.last.space_id).to eq 2
      expect(listings.last.listed_by).to eq 2
      expect(listings.last.booked_from).to eq Date.new(2022, 11, 1)
      expect(listings.last.booked_to).to eq Date.new(2022, 11, 1)
      expect(listings.last.status).to eq 'confirmed'
    end

    it 'returns false if there is no match' do
      listed_by = 5

      repo = BookingRepository.new

      listings = repo.find_active_listing(listed_by)
      expect(listings).to eq false
    end
  end

  describe '#find_booking_for_space' do
    it 'returns an array of Booking objects given their space_id' do
      space_id = 2

      repo = BookingRepository.new

      bookings = repo.find_booking_for_space(space_id)

      expect(bookings.length).to eq 4
      expect(bookings.last.id).to eq 6
      expect(bookings.last.booked_by).to eq 3
      expect(bookings.last.space_id).to eq 2
      expect(bookings.last.listed_by).to eq 2
      expect(bookings.last.booked_from).to eq Date.new(2022, 11, 2)
      expect(bookings.last.booked_to).to eq Date.new(2022, 11, 2)
      expect(bookings.last.status).to eq 'archived'
    end

    it 'return false if there is no match' do
      space_id = 4

      repo = BookingRepository.new

      bookings = repo.find_booking_for_space(space_id)
      expect(bookings).to eq false
    end
  end

  describe '#create_booking' do
    it 'adds a new booking to the bookings table' do
      booking = Booking.new
      booking.booked_by = 5
      booking.space_id = 1
      booking.listed_by = 1
      booking.booked_from = Date.new(2022, 12, 15)
      booking.booked_to = Date.new(2022, 12, 15)
      booking.status = 'pending'

      repo = BookingRepository.new
      repo.create_booking(booking)

      expect(repo.all).to include(
        have_attributes(
          booked_by: 5,
          space_id: 1,
          listed_by: 1,
          booked_from: Date.parse('2022-12-15'),
          booked_to: Date.parse('2022-12-15'),
          status: 'pending'
        )
      )
    end
  end

  describe '#cancel_booking' do
    it 'changes the status of a booking to cancelled' do
      booking_to_cancel = 3
      repo = BookingRepository.new
      booking = repo.find_booking(booking_to_cancel)
      expect(booking.status).to eq 'pending'
      repo.cancel_booking(booking.id)
      booking = repo.find_booking(booking_to_cancel)
      expect(booking.status).to eq 'cancelled'
    end
  end

  describe '#validate_booking' do
    it 'returns true if the space is available for a given date' do
      booking = Booking.new
      booking.booked_by = 1
      booking.space_id = 2
      booking.booked_from = '2022-11-10'
      booking.booked_to = '2022-11-10'
      booking.status = 'pending'

      repo = BookingRepository.new

      expect(repo.validate_booking(booking)).to eq true
    end

    it 'return false if the space is not available for a given date' do
      booking = Booking.new
      booking.booked_by = 1
      booking.space_id = 3
      booking.booked_from = '2022-12-01'
      booking.booked_to = '2022-12-01'
      booking.status = 'confirmed'

      repo = BookingRepository.new

      expect(repo.validate_booking(booking)).to eq false
    end
  end

  describe '#confirm_booking' do
    it 'changes the status of a booking to confirmed' do
      booking_to_confirm = 4
      repo = BookingRepository.new
      booking = repo.find_booking(booking_to_confirm)
      expect(booking.status).to eq 'pending'
      repo.confirm_booking(booking.id)
      booking = repo.find_booking(booking_to_confirm)
      expect(booking.status).to eq 'confirmed'
    end
  end

  describe '#archive_past_bookings' do
    it 'changes the status of all past booking to `archived`' do
      repo = BookingRepository.new

      repo.archive_past_bookings

      bookings = repo.all

      count = 0
      bookings.each { |booking| count += 1 if booking.status == 'archived' }

      expect(count).to eq 2
    end
  end

  describe '#find_past_booking' do
    it 'returns all archived bookings for a given user' do
      booked_by = 3
      repo = BookingRepository.new
      past_bookings = repo.find_past_booking(booked_by)

      expect(past_bookings.length).to eq 1
      expect(past_bookings.first.booked_by).to eq 3
      expect(past_bookings.first.space_id).to eq 2
      expect(past_bookings.first.listed_by).to eq 2
      expect(past_bookings.first.booked_from).to eq Date.new(2022, 11, 0o2)
      expect(past_bookings.first.booked_to).to eq Date.new(2022, 11, 0o2)
      expect(past_bookings.first.status).to eq 'archived'
    end

    it 'returns false if there is no match' do
      booked_by = 2

      repo = BookingRepository.new

      past_bookings = repo.find_past_booking(booked_by)
      expect(past_bookings).to eq false
    end
  end
end
