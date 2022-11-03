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

-- Create the join table.
CREATE TABLE users_spaces (
  booked_by int,
  space_id int,
  constraint fk_user foreign key(booked_by) references users(id) on delete cascade,
  constraint fk_space foreign key(space_id) references spaces(id) on delete cascade,
  PRIMARY KEY (booked_by, space_id),
  date date,
  status text
);