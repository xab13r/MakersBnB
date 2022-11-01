# Table Design


## Table Name and Columns

| Record                | Properties          |
| --------------------- | ------------------  |
| users                 | email, password
| spaces                | name, description, price per night, start date, end date

`users` 

    Column names: `email`, `password`

`spaces` 

    Column names: `name`, `description`, `price_night`, `start-date`, `end_date`

## 3. Column types.

```
Table: users
id: SERIAL
email: text
password: text

Table: spaces
id: SERIAL
name: text
description: text
price_night: float
start_date: date
end_date: date
```

## 5. Design the Join Table

```
Join table for tables: users and spaces
Join table name: users_spaces
Columns: user_id, space_id, date, status
```

## 4. Write the SQL.

```sql
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

# changed name of table to spaces and added user id to table ^^

-- Create the join table.
CREATE TABLE users_spaces (
  user_id int,
  space_id int,
  constraint fk_user foreign key(user_id) references users(id) on delete cascade,
  constraint fk_space foreign key(space_id) references spaces(id) on delete cascade,
  PRIMARY KEY (user_id, space_id),
  date date,
  status text
);

```

## 5. Create the tables.

```bash
psql -h 127.0.0.1 makersbnb_test < spec/users_spaces.sql
psql -h 127.0.0.1 makersbnb_production < spec/users_spaces.sql
```