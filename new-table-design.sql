CREATE TABLE bookings (
ID SERIAL PRIMARY key,
booked_by INT,
space_id INT,
listed_by INT,
CONSTRAINT fk_booked_by FOREIGN KEY(booked_by) REFERENCES users(id) on DELETE CASCADE,
CONSTRAINT fk_space_id FOREIGN KEY(space_id) REFERENCES spaces(id) on DELETE CASCADE,
CONSTRAINT fk_listed_by FOREIGN KEY(listed_by) REFERENCES spaces(user_id) on DELETE cascade,
booked_from date,
booked_to date,
status text
);
