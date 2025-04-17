-- Active: 1743889130285@@127.0.0.1@5432@moviebookings

CREATE DATABASE movieBookings;

CREATE TABLE admin(
    id SERIAL PRIMARY KEY,
    username varchar(30)  NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    token VARCHAR(50) 
);


INSERT INTO admin(username,password) VALUES
('shabaz patel','Shabaz@07');

SELECT * FROM admin;


CREATE Table customers(
    id SERIAL PRIMARY KEY,
    username varchar(30)  NOT NULL,
    email VARCHAR(30)  UNIQUE NOT NULL UNIQUE,
    phone_number VARCHAR(10) UNIQUE NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    token VARCHAR(50)
);
INSERT INTO customers(username,email,phone_number,password) VALUES
('Shabaz','example@email.com','7890234512','Shabaz@07');

SELECT * FROM customers;

CREATE TABLE showTimes (
    id SERIAL PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

INSERT INTO showTimes (start_time, end_time) VALUES
('10:00:00', '13:00:00'),
('13:30:00', '16:30:00'),
('17:00:00', '20:00:00'),
('20:30:00', '23:30:00');

SELECT * FROM showTimes;

CREATE TYPE status_enum AS ENUM ('Available', 'Unavailable','Coming Soon');
CREATE TABLE theaters (
    id SERIAL PRIMARY KEY,  
    name VARCHAR(30) NOT NULL UNIQUE,
    location VARCHAR(50) NOT NULL,
    screens INT NOT NULL,
    showTime INT NOT NULL REFERENCES showTimes(id),
    status status_enum DEFAULT 'Available'
);

INSERT INTO theaters (name, location, screens, showTime, status) VALUES
('PVR Inorbit Mall', 'Inorbit Mall, Madhapur, Hyderabad', 5, 1, 'Available'),
('AMB Cinemas Gachibowli', 'Gachibowli, Hyderabad', 8, 2, 'Available'),
('INOX GVK One', 'GVK One Mall, Banjara Hills, Hyderabad', 6, 3, 'Available'),
('Miraj Cinemas Asian Radhika', 'ECIL, Hyderabad', 4, 4, 'Available'),
('Cinepolis Mantra Mall', 'Mantra Mall, Attapur, Hyderabad', 7, 1, 'Coming Soon'),
('Sudarshan 35mm', 'RTC X Roads, Hyderabad', 2, 2, 'Available'),
('Devi 70MM', 'RTC X Roads, Hyderabad', 1, 3, 'Unavailable');

SELECT * FROM theaters;

create table movie_categories(
    id SERIAL PRIMARY KEY,
    description VARCHAR(10) NOT NULL UNIQUE
);

INSERT INTO movie_categories (description) VALUES
('Bollywood'),
('Tollywood'),
('Hollywood'),
('Kids');

SELECT * FROM movie_categories;

CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    poster TEXT NOT NULL,
    title VARCHAR(30) NOT NULL UNIQUE,
    released_date DATE NOT NULL,
    category_id INT NOT NULL REFERENCES movie_categories(id),
    genre VARCHAR(50) NOT NULL,
    actors VARCHAR(255) NOT NULL,
    status status_enum DEFAULT 'Available',
    description TEXT,
    duration TIME,
    rating DECIMAL(2,1) CHECK(rating <= 5.0) NOT NULL
);


INSERT INTO movies (poster, title, released_date, category_id, genre, actors,status, description, duration, rating) VALUES
('bollywood_poster1.jpg', 'Sholay', '1975-08-15', 1, 'Action, Adventure', 'Dharmendra, Amitabh Bachchan, Hema Malini','Unavailable', 'A classic tale of two criminals hired to capture a ruthless dacoit.', '3h 14m', '9.0'),
('tollywood_poster1.jpg', 'Baahubali: The Beginning', '2015-07-10', 2, 'Action, Drama, Fantasy', 'Prabhas, Rana Daggubati, Anushka Shetty','Available', 'An epic story about two warring brothers vying for control of an ancient kingdom.', '2h 39m', '8.1'),
('hollywood_poster1.jpg', 'The Shawshank Redemption', '1994-09-23', 3, 'Drama', 'Tim Robbins, Morgan Freeman','Available', 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.', '2h 22m', '9.3'),
('kids_poster1.jpg', 'Toy Story', '1995-11-22', 4, 'Animation, Adventure, Comedy', 'Tom Hanks, Tim Allen, Don Rickles','Available', 'A cowboy doll is profoundly threatened and jealous when a new spaceman figure supplants him as top toy in a boy room.', '1h 21m', '8.3'),
('bollywood_poster2.jpg', 'Dilwale Dulhania Le Jayenge', '1995-10-20', 1, 'Comedy, Drama, Romance', 'Shah Rukh Khan, Kajol','Unavailable', 'A young man and woman fall in love on a trip to Europe and subsequently try to win over the woman traditional parents.', '3h 9m', '8.0'),
('tollywood_poster2.jpg', 'Magadheera', '2009-07-31', 2, 'Action, Drama, Fantasy', 'Ram Charan, Kajal Aggarwal','Coming Soon', 'A brave warrior of ancient India is reborn in modern times and rediscovers his love and a long-standing conflict.', '2h 47m', '7.8'),
('hollywood_poster2.jpg', 'The Dark Knight', '2008-07-18', 3, 'Action, Crime, Drama', 'Christian Bale, Heath Ledger, Aaron Eckhart','Coming Soon', 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.', '2h 32m', '9.0'),
('kids_poster2.jpg', 'The Lion King', '1994-06-24', 4, 'Animation, Adventure, Drama', 'Matthew Broderick, Jeremy Irons, James Earl Jones','Available', 'A young lion prince is forced to flee his kingdom after his uncle murders his father and claims the throne.', '1h 28m', '8.5');

SELECT * FROM movies;



CREATE TABLE movieShows (
    id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES movies(id),
    theater_id INT NOT NULL REFERENCES theaters(id),
    movie_category_id INT NOT NULL REFERENCES movie_categories(id),
    movie_title VARCHAR(30) NOT NULL REFERENCES movies(title),
    show_time_id INT NOT NULL REFERENCES showTimes(id),
    movie_screens INT NOT NULL,
    theater_name VARCHAR(30) NOT NULL REFERENCES theaters(name),
    status status_enum DEFAULT 'Available'
);

SELECT * FROM movieShows;

DROP TABLE  CASCADE;


SELECT m.id,m.title,m.released_date,mc.description,m.genre,m.actors,m.status FROM movies m JOIN movie_categories mc on m.category_id = mc.id WHERE mc.id=1;

SELECT t.id,t.name,t.location,t.screens,st.start_time,t.status FROM theaters t JOIN showTimes st ON t.showTime = st.id;

INSERT INTO movieShows(movie_id, theater_id, movie_category_id, movie_title, show_time_id,movie_screens, theater_name, status) VALUES
(1, 1, 1, (SELECT title FROM movies WHERE id = 1), 1,3, (SELECT name FROM theaters WHERE id = 1), 'Available');

SELECT * FROM movieShows;

CREATE TABLE bookShow(
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    movie_category_id INT NOT NULL REFERENCES movie_categories(id),
    movie_id INT NOT NULL REFERENCES movies(id),
    theater_id INT NOT NULL REFERENCES theaters(id),
    show_time_id INT NOT NULL REFERENCES showTimes(id),
    bookingStatus VARCHAR(15) CHECK(bookingStatus IN ('Booked','Not Booked')) DEFAULT 'Booked'
);

INSERT INTO bookShow(customer_id,movie_category_id,movie_id,theater_id,show_time_id,bookingStatus) VALUES
(1,1,1,1,1,'Booked'),
(1,1,1,1,2,'Booked');

select*from bookShow;

SELECT c.username,mc.description,m.title,t.name,st.start_time,bs.bookingStatus FROM bookShow bs 
JOIN movie_categories mc on mc.id = bs.movie_category_id
JOIN movies m ON m.id = bs.movie_id
JOIN theaters t ON t.id = bs.theater_id
JOIN showTimes st ON st.id = bs.show_time_id
JOIN customers c ON t.id = bs.customer_id;

INSERT INTO movies()