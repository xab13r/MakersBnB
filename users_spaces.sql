-- file: users_spaces.sql

-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name text,
  email text,
  password text
);

-- Spaces table
CREATE TABLE spaces (
  id SERIAL PRIMARY KEY,
  name text,
  description text,
  price_night float,
  start_date date,
  end_date date,
  user_id int,
  constraint fk_user foreign key(user_id) references users(id) on delete cascade
);

CREATE TABLE bookings (
ID SERIAL PRIMARY key,
booked_by INT,
space_id INT,
listed_by INT,
CONSTRAINT fk_booked_by FOREIGN KEY(booked_by) REFERENCES users(id) on DELETE CASCADE,
CONSTRAINT fk_space_id FOREIGN KEY(space_id) REFERENCES spaces(id) on DELETE CASCADE,
CONSTRAINT fk_listed_by FOREIGN KEY(listed_by) REFERENCES users(id) on DELETE cascade,
booked_from date,
booked_to date,
status text
);
