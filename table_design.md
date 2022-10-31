# Table Design


## Table Name and Columns

| Record                | Properties          |
| --------------------- | ------------------  |
| users                 | email, password
| spaces                | name, description, price per night
| dates                 | date

`users` 

    Column names: `email`, `password`

`spaces` 

    Column names: `name`, `description`, `price_night`

`dates` 

    Column names: `date`


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

Table: dates
id: SERIAL
date: date
```

## 5. Design the Join Table

```
Join table for tables: spaces and dates
Join table name: spaces_dates
Columns: space_id, date_id, user_id, status
```

## 4. Write the SQL.

```sql
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

```

## 5. Create the tables.

```bash
psql -h 127.0.0.1 makersbnb_test < spec/spaces_dates.sql
psql -h 127.0.0.1 makersbnb_production < spec/spaces_dates.sql
```