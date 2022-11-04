-- Disable Notice messages in RSpec
SET client_min_messages TO WARNING;

-- Testing seeds
TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE spaces RESTART IDENTITY CASCADE;
TRUNCATE TABLE users_spaces RESTART IDENTITY CASCADE;

INSERT INTO users (name, email, password) VALUES
('user 1', 'email_1@email.com', '$2a$12$7mfDByVKXH/lhYEyw0WXr.mLZ5QP5XsdmruSM/YCKiUav2IGpgr32'), -- 'strong password'
('user 2', 'email_2@email.com', '$2a$12$hUioakBqsrZba1ewCmc28uqEYkghNy8Mb37rl1baBEJWD3usufi4a'), -- 'strong password 1'
('user 3', 'email_3@email.com', '$2a$12$4U47Io6SqemEM6Z7dtDMaOEuMLvc4zZuF.vN/x3leVAxl6/38a2Le'), -- 'strong password 2'
('user 4', 'email_4@email.com', '$2a$12$I7cIVdo4bVtL7r8Tgq0tr.ywyHZQsXZ1ZUI2MxpkZHCueKC5CAGSe'), -- 'strong password 3'
('user 5', 'email_5@email.com', '$2a$12$I7cIVdo4bVtL7r8Tgq0tr.ywyHZQsXZ1ZUI2MxpkZHCueKC5CAGSe'), -- 'strong password 3'
('user 5', 'email_6@email.com', '$2a$12$I7cIVdo4bVtL7r8Tgq0tr.ywyHZQsXZ1ZUI2MxpkZHCueKC5CAGSe'); -- 'strong password 3'

INSERT INTO spaces (name, description, price_night, start_date, end_date, user_id) VALUES
('fancy space', 'this is a fancy space', 100.0, '2022-11-01', '2022-12-01', 1),
('fancier space', 'this is a fancier space', 200.0, '2022-10-31', '2022-11-15', 2),
('not so fancy space', 'this is a not so fancy space', 40.0, '2022-11-15', '2022-12-15', 3),
('spartan space', 'this is a spartan space', 20.0, '2022-12-15', '2023-01-15', 1),
('long description space', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 150.0, '2023-01-1', '2023-01-31', 1),
('spartan space', 'this is a spartan space', 20.0, '2022-12-15', '2023-01-15', 3);

INSERT INTO bookings (booked_by, space_id, listed_by, booked_from, booked_to, status) VALUES
(1, 3, 3, '2022-12-01', '2022-12-01', 'confirmed'),
(2, 1, 1, '2022-11-15', '2022-11-15', 'confirmed'),
(3, 2, 2, '2022-11-10', '2022-11-10', 'pending'),
(4, 2, 2, '2022-11-10', '2022-11-10', 'pending'),
(1, 2, 2, '2022-11-01', '2022-11-01', 'confirmed'), -- record to be archived
(3, 2, 2, '2022-11-02', '2022-11-02', 'archived'), -- record to be archived
(2, 5, 1, '2022-12-31', '2022-12-31', 'confirmed');