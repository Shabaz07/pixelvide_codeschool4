-- Active: 1743889130285@@127.0.0.1@5432@employee_management
CREATE DATABASE employee_management;


CREATE Table admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(32) NOT NULL,
    token VARCHAR(255) 
);
INSERT INTO admin (username,password) VALUES(
    'Shabaz',md5('Shabaz@07')
);
SELECT * FROM admin;

-- WORKING STATUS TABLE (create,insert,display)
CREATE Table working_status(
    id SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO working_status (description) VALUES 
('Working'), ('Expired'), ('Retired'), ('Suspended');

SELECT * FROM working_status;


-- DESIGNATION TABLE (create,insert,display)
CREATE Table designations(
    id SERIAL PRIMARY KEY,
    description VARCHAR(70) NOT NULL UNIQUE
);

INSERT INTO designations (description) VALUES 
('Software Engineer'), ('Project Manager'), ('HR Manager'), ('Data Analyst'), ('System Administrator');

SELECT * FROM designations;

-- LOCATIONS TABLE (create,insert,display)
CREATE Table location(
    id SERIAL PRIMARY KEY,
    district VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO location (district) VALUES 
('Hyderabad'), ('Medak'), ('Karimnagar'), ('Mahbubnagar'), ('Ranga Reddy'), ('Medchal');

SELECT * FROM location;

CREATE TABLE gender (
    id SERIAL PRIMARY KEY,
    gender VARCHAR(10) NOT NULL CHECK (gender = 'Male' OR gender = 'Female' OR gender = 'Others')
);

INSERT INTO gender (gender) VALUES 
('Male'),
('Female'),
('Others');

SELECT * FROM gender;


-- EMPLOYEES TABLE (create,insert,display)
CREATE Table employees(
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(20) NOT NUll,
    lastName VARCHAR(20) NOT NUll,    
    surname VARCHAR(20) NOT NULL,
    doj DATE NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(10) NOT NULL UNIQUE,
    gender_id INT NOT NULL REFERENCES gender(id) ON DELETE CASCADE,
    working_status_id INT REFERENCES working_status(id) NOT NULL,
    designation_id INT REFERENCES designations(id) NOT NULL,
    location_id INT REFERENCES location(id) NOT NULL,
    gross NUMERIC(10,2) NOT NULL CHECK(gross >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- GENDER TABLE
CREATE TABLE gender (
    id SERIAL PRIMARY KEY,
    gender VARCHAR(10) NOT NULL CHECK (gender = 'Male' OR gender = 'Female' OR gender = 'Others')
);

INSERT INTO gender (gender) VALUES 
('Male'),
('Female'),
('Others');

-- EMPLOYEES TABLE
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(20) NOT NULL,
    lastName VARCHAR(20) NOT NULL,    
    surname VARCHAR(20) NOT NULL,
    doj DATE NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(10) NOT NULL UNIQUE,
    gender_id INT NOT NULL REFERENCES gender(id) ON DELETE CASCADE,
    working_status_id INT NOT NULL REFERENCES working_status(id),
    designation_id INT NOT NULL REFERENCES designations(id),
    location_id INT NOT NULL REFERENCES location(id),
    gross NUMERIC(10,2) NOT NULL CHECK(gross >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CORRECTED INSERT STATEMENTS (using gender_id instead of gender)
INSERT INTO employees (
    firstName, lastName, surname, doj, dob, phone, gender_id, 
    working_status_id, designation_id, location_id, gross
) VALUES
('Amit', 'Sharma', 'Kumar', '2018-06-15', '1990-02-10', '9876543201', 1, 1, 1, 1, 75000),
('Sneha', 'Patel', 'Rao', '2019-07-10', '1992-05-14', '9876543202', 2, 1, 2, 2, 90000),
('Ravi', 'Verma', 'Singh', '2020-09-20', '1993-08-25', '9876543203', 1, 1, 3, 3, 60000),
('Priya', 'Iyer', 'Nair', '2017-11-30', '1991-12-05', '9876543204', 2, 1, 4, 4, 85000),
('Vikas', 'Mishra', 'Pandey', '2021-03-12', '1995-09-18', '9876543205', 1, 2, 5, 5, 70000),
('Raj', 'Kapoor', 'Yadav', '2015-08-10', '1988-07-30', '9876543206', 1, 3, 2, 6, 50000),
('Sunita', 'Das', 'Roy', '2016-05-22', '1989-06-21', '9876543207', 2, 3, 1, 1, 65000),
('Arjun', 'Reddy', 'Gowda', '2019-04-15', '1994-11-17', '9876543208', 1, 4, 3, 2, 58000),
('Megha', 'Joshi', 'Thakur', '2018-10-05', '1990-01-29', '9876543209', 2, 1, 5, 3, 72000),
('Rahul', 'Ghosh', 'Chatterjee', '2020-12-20', '1996-03-05', '9876543210', 1, 1, 1, 4, 80000);

SELECT * FROM employees;



-- SALARY COMPONENTS TABLE (create,insert,display)
CREATE Table salary_components(
    id SERIAL PRIMARY KEY,
    description VARCHAR(100) NOT NULL UNIQUE,
    type INT NOT NULL CHECK(type IN(1,2))
);

INSERT INTO salary_components (description, type) VALUES 
('Basic', 1), ('DA', 1), ('HRA', 1), ('CA', 1), ('Medical Allowance', 1), ('Bonus', 1),
('TDS', 2), ('PF', 2);

SELECT * FROM salary_components;

-- SALARIES TABLE (create,insert,display)
CREATE TABLE salaries (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    month INT CHECK (month BETWEEN 1 AND 12),
    year INT NOT NULL,
    paid_on DATE,
    gross NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deduction DECIMAL(10, 2) NOT NULL,
    net DECIMAL(10, 2) GENERATED ALWAYS AS (gross - deduction) STORED
);

INSERT INTO salaries (employee_id, month, year, paid_on, gross, deduction) VALUES
(1, 1, 2025, '2025-02-01', 75000.00, 7500.00),
(1, 2, 2025, '2025-03-01', 75000.00, 7500.00),
(1, 3, 2025, '2025-04-01', 75000.00, 7500.00),
(2, 1, 2025, '2025-02-01', 90000.00, 9000.00),
(2, 2, 2025, '2025-03-01', 90000.00, 9000.00),
(2, 3, 2025, '2025-04-01', 90000.00, 9000.00),
(3, 1, 2025, '2025-02-01', 60000.00, 6000.00),
(3, 2, 2025, '2025-03-01', 60000.00, 6000.00),
(3, 3, 2025, '2025-04-01', 60000.00, 6000.00),
(4, 1, 2025, '2025-02-01', 85000.00, 8500.00),
(4, 2, 2025, '2025-03-01', 85000.00, 8500.00),
(4, 3, 2025, '2025-04-01', 85000.00, 8500.00),
(5, 1, 2025, '2025-02-01', 70000.00, 7000.00),
(5, 2, 2025, '2025-03-01', 70000.00, 7000.00),
(5, 3, 2025, '2025-04-01', 70000.00, 7000.00),
(6, 1, 2025, '2025-02-01', 50000.00, 5000.00),
(6, 2, 2025, '2025-03-01', 50000.00, 5000.00),
(6, 3, 2025, '2025-04-01', 50000.00, 5000.00),
(7, 1, 2025, '2025-02-01', 65000.00, 6500.00),
(7, 2, 2025, '2025-03-01', 65000.00, 6500.00),
(7, 3, 2025, '2025-04-01', 65000.00, 6500.00),
(8, 1, 2025, '2025-02-01', 58000.00, 5800.00),
(8, 2, 2025, '2025-03-01', 58000.00, 5800.00),
(8, 3, 2025, '2025-04-01', 58000.00, 5800.00),
(9, 1, 2025, '2025-02-01', 72000.00, 7200.00),
(9, 2, 2025, '2025-03-01', 72000.00, 7200.00),
(9, 3, 2025, '2025-04-01', 72000.00, 7200.00),
(10, 1, 2025, '2025-02-01', 80000.00, 8000.00),
(10, 2, 2025, '2025-03-01', 80000.00, 8000.00),
(10, 3, 2025, '2025-04-01', 80000.00, 8000.00);


SELECT * FROM salaries;

-- SALARY DETAILS TABLE
CREATE TABLE salary_details (
    id SERIAL PRIMARY KEY,
    salary_id INT REFERENCES salaries(id),
    salary_component_id INT REFERENCES salary_components(id),
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO salary_details (salary_id, salary_component_id, amount) VALUES
(1, 1, 30000.00), (1, 2, 10000.00), (1, 3, 10000.00), (1, 4, 5000.00), (1, 5, 2000.00), (1, 6, 5000.00), (1, 7, 3750.00), (1, 8, 3750.00),
(2, 1, 30000.00), (2, 2, 10000.00), (2, 3, 10000.00), (2, 4, 5000.00), (2, 5, 2000.00), (2, 6, 5000.00), (2, 7, 3750.00), (2, 8, 3750.00),
(3, 1, 30000.00), (3, 2, 10000.00), (3, 3, 10000.00), (3, 4, 5000.00), (3, 5, 2000.00), (3, 6, 5000.00), (3, 7, 3750.00), (3, 8, 3750.00),
(4, 1, 36000.00), (4, 2, 12000.00), (4, 3, 12000.00), (4, 4, 6000.00), (4, 5, 2400.00), (4, 6, 6000.00), (4, 7, 4500.00), (4, 8, 4500.00),
(5, 1, 36000.00), (5, 2, 12000.00), (5, 3, 12000.00), (5, 4, 6000.00), (5, 5, 2400.00), (5, 6, 6000.00), (5, 7, 4500.00), (5, 8, 4500.00),
(6, 1, 36000.00), (6, 2, 12000.00), (6, 3, 12000.00), (6, 4, 6000.00), (6, 5, 2400.00), (6, 6, 6000.00), (6, 7, 4500.00), (6, 8, 4500.00),
(7, 1, 24000.00), (7, 2, 8000.00), (7, 3, 8000.00), (7, 4, 4000.00), (7, 5, 1600.00), (7, 6, 4000.00), (7, 7, 3000.00), (7, 8, 3000.00),
(8, 1, 24000.00), (8, 2, 8000.00), (8, 3, 8000.00), (8, 4, 4000.00), (8, 5, 1600.00), (8, 6, 4000.00), (8, 7, 3000.00), (8, 8, 3000.00),
(9, 1, 24000.00), (9, 2, 8000.00), (9, 3, 8000.00), (9, 4, 4000.00), (9, 5, 1600.00), (9, 6, 4000.00), (9, 7, 3000.00), (9, 8, 3000.00),
(10, 1, 34000.00), (10, 2, 11333.00), (10, 3, 11333.00), (10, 4, 5667.00), (10, 5, 2267.00), (10, 6, 5667.00), (10, 7, 4250.00), (10, 8, 4250.00),
(11, 1, 34000.00), (11, 2, 11333.00), (11, 3, 11333.00), (11, 4, 5667.00), (11, 5, 2267.00), (11, 6, 5667.00), (11, 7, 4250.00), (11, 8, 4250.00),
(12, 1, 34000.00), (12, 2, 11333.00), (12, 3, 11333.00), (12, 4, 5667.00), (12, 5, 2267.00), (12, 6, 5667.00), (12, 7, 4250.00), (12, 8, 4250.00),
(13, 1, 28000.00), (13, 2, 9333.00), (13, 3, 9333.00), (13, 4, 4667.00), (13, 5, 1867.00), (13, 6, 4667.00), (13, 7, 3500.00), (13, 8, 3500.00),
(14, 1, 28000.00), (14, 2, 9333.00), (14, 3, 9333.00), (14, 4, 4667.00), (14, 5, 1867.00), (14, 6, 4667.00), (14, 7, 3500.00), (14, 8, 3500.00),
(15, 1, 28000.00), (15, 2, 9333.00), (15, 3, 9333.00), (15, 4, 4667.00), (15, 5, 1867.00), (15, 6, 4667.00), (15, 7, 3500.00), (15, 8, 3500.00),
(16, 1, 20000.00), (16, 2, 6667.00), (16, 3, 6667.00), (16, 4, 3333.00), (16, 5, 1333.00), (16, 6, 3333.00), (16, 7, 2500.00), (16, 8, 2500.00),
(17, 1, 20000.00), (17, 2, 6667.00), (17, 3, 6667.00), (17, 4, 3333.00), (17, 5, 1333.00), (17, 6, 3333.00), (17, 7, 2500.00), (17, 8, 2500.00),
(18, 1, 20000.00), (18, 2, 6667.00), (18, 3, 6667.00), (18, 4, 3333.00), (18, 5, 1333.00), (18, 6, 3333.00), (18, 7, 2500.00), (18, 8, 2500.00),
(19, 1, 26000.00), (19, 2, 8667.00), (19, 3, 8667.00), (19, 4, 4333.00), (19, 5, 1733.00), (19, 6, 4333.00), (19, 7, 3250.00), (19, 8, 3250.00),
(20, 1, 26000.00), (20, 2, 8667.00), (20, 3, 8667.00), (20, 4, 4333.00), (20, 5, 1733.00), (20, 6, 4333.00), (20, 7, 3250.00), (20, 8, 3250.00),
(21, 1, 26000.00), (21, 2, 8667.00), (21, 3, 8667.00), (21, 4, 4333.00), (21, 5, 1733.00), (21, 6, 4333.00), (21, 7, 3250.00), (21, 8, 3250.00),
(22, 1, 23200.00), (22, 2, 7733.00), (22, 3, 7733.00), (22, 4, 3867.00), (22, 5, 1547.00), (22, 6, 3867.00), (22, 7, 2900.00), (22, 8, 2900.00),
(23, 1, 23200.00), (23, 2, 7733.00), (23, 3, 7733.00), (23, 4, 3867.00), (23, 5, 1547.00), (23, 6, 3867.00), (23, 7, 2900.00), (23, 8, 2900.00),
(24, 1, 23200.00), (24, 2, 7733.00), (24, 3, 7733.00), (24, 4, 3867.00), (24, 5, 1547.00), (24, 6, 3867.00), (24, 7, 2900.00), (24, 8, 2900.00),
(25, 1, 28800.00), (25, 2, 9600.00), (25, 3, 9600.00), (25, 4, 4800.00), (25, 5, 1920.00), (25, 6, 4800.00), (25, 7, 3600.00), (25, 8, 3600.00),
(26, 1, 28800.00), (26, 2, 9600.00), (26, 3, 9600.00), (26, 4, 4800.00), (26, 5, 1920.00), (26, 6, 4800.00), (26, 7, 3600.00), (26, 8, 3600.00),
(27, 1, 28800.00), (27, 2, 9600.00), (27, 3, 9600.00), (27, 4, 4800.00), (27, 5, 1920.00), (27, 6, 4800.00), (27, 7, 3600.00), (27, 8, 3600.00),
(28, 1, 32000.00), (28, 2, 10667.00), (28, 3, 10667.00), (28, 4, 5333.00), (28, 5, 2133.00), (28, 6, 5333.00), (28, 7, 4000.00), (28, 8, 4000.00),
(29, 1, 32000.00), (29, 2, 10667.00), (29, 3, 10667.00), (29, 4, 5333.00), (29, 5, 2133.00), (29, 6, 5333.00), (29, 7, 4000.00), (29, 8, 4000.00),
(30, 1, 32000.00), (30, 2, 10667.00), (30, 3, 10667.00), (30, 4, 5333.00), (30, 5, 2133.00), (30, 6, 5333.00), (30, 7, 4000.00), (30, 8, 4000.00);

SELECT * FROM salary_details;

--1st emp list
SELECT 
    CONCAT(e.firstname, ' ', e.lastname, ' ', e.surname) AS name,
    e.doj,
    e.dob,
    g.gender,
    e.phone,
    ws.description AS working_status,
    d.description AS designation,
    l.district AS location
FROM employees e
JOIN gender g ON e.gender_id = g.id
JOIN working_status ws ON e.working_status_id = ws.id
JOIN designations d ON e.designation_id = d.id
JOIN location l ON e.location_id = l.id;
