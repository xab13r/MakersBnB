-- file: space_date.sql

-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email text,
  password text
);

-- Spaces table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name text,
  description text,
  price_night float
);

-- Dates table
CREATE TABLE dates (
  id SERIAL PRIMARY KEY,
  date date,
);

-- Create the join table.
CREATE TABLE spaces_dates (
  space_id int,
  date_id int,
  user_id int,
  status text,
  constraint fk_space foreign key(space_id) references spaces(id) on delete cascade,
  constraint fk_date foreign key(date_id) references dates(id) on delete cascade,
  constraint fk_user foreign key(user_id) references users(id) on delete cascade,
  PRIMARY KEY (space_id, date_id)
);