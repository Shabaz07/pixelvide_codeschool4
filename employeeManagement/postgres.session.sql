-- Active: 1743889130285@@127.0.0.1@5432@employee_management
CREATE DATABASE employee_management;

CREATE Table admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(10) NOT NULL
);
INSERT INTO admin (username,password) VALUES(
    'Shabaz','Shabaz@07'
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMEST1
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
(1, 1, 2025, '2025-02-01', 60000.00, 6000.00),
(1, 2, 2025, '2025-03-01', 61000.00, 6100.00),
(2, 1, 2025, '2025-02-01', 80000.00, 8000.00),
(2, 2, 2025, '2025-03-01', 82000.00, 8200.00),
(3, 1, 2025, '2025-02-01', 55000.00, 5500.00),
(3, 2, 2025, '2025-03-01', 56000.00, 5600.00),
(4, 1, 2025, '2025-02-01', 65000.00, 6500.00),
(4, 2, 2025, '2025-03-01', 66000.00, 6600.00),
(5, 1, 2025, '2025-02-01', 70000.00, 7000.00),
(5, 2, 2025, '2025-03-01', 71000.00, 7100.00),
(6, 1, 2025, '2025-02-01', 62000.00, 6200.00),
(6, 2, 2025, '2025-03-01', 63000.00, 6300.00),
(7, 1, 2025, '2025-02-01', 75000.00, 7500.00),
(7, 2, 2025, '2025-03-01', 76000.00, 7600.00),
(8, 1, 2025, '2025-02-01', 58000.00, 5800.00),
(8, 2, 2025, '2025-03-01', 59000.00, 5900.00),
(9, 1, 2025, '2025-02-01', 67000.00, 6700.00),
(9, 2, 2025, '2025-03-01', 68000.00, 6800.00),
(10, 1, 2025, '2025-02-01', 72000.00, 7200.00),
(10, 2, 2025, '2025-03-01', 73000.00, 7300.00),
(11, 1, 2025, '2025-02-01', 61000.00, 6100.00),
(11, 2, 2025, '2025-03-01', 62000.00, 6200.00),
(12, 1, 2025, '2025-02-01', 78000.00, 7800.00),
(12, 2, 2025, '2025-03-01', 79000.00, 7900.00),
(13, 1, 2025, '2025-02-01', 59000.00, 5900.00),
(13, 2, 2025, '2025-03-01', 60000.00, 6000.00),
(14, 1, 2025, '2025-02-01', 64000.00, 6400.00),
(14, 2, 2025, '2025-03-01', 65000.00, 6500.00),
(15, 1, 2025, '2025-02-01', 73000.00, 7300.00),
(15, 2, 2025, '2025-03-01', 74000.00, 7400.00),
(16, 1, 2025, '2025-02-01', 66000.00, 6600.00),
(16, 2, 2025, '2025-03-01', 67000.00, 6700.00),
(17, 1, 2025, '2025-02-01', 79000.00, 7900.00),
(17, 2, 2025, '2025-03-01', 80000.00, 8000.00),
(18, 1, 2025, '2025-02-01', 57000.00, 5700.00),
(18, 2, 2025, '2025-03-01', 58000.00, 5800.00),
(19, 1, 2025, '2025-02-01', 68000.00, 6800.00),
(19, 2, 2025, '2025-03-01', 69000.00, 6900.00),
(20, 1, 2025, '2025-02-01', 71000.00, 7100.00),
(20, 2, 2025, '2025-03-01', 72000.00, 7200.00),
(1, 12, 2024, '2025-01-01', 59000.00, 5900.00),
(2, 12, 2024, '2025-01-01', 79000.00, 7900.00),
(3, 12, 2024, '2025-01-01', 54000.00, 5400.00),
(4, 12, 2024, '2025-01-01', 64000.00, 6400.00),
(5, 12, 2024, '2025-01-01', 69000.00, 6900.00),
(6, 12, 2024, '2025-01-01', 61000.00, 6100.00),
(7, 12, 2024, '2025-01-01', 74000.00, 7400.00),
(8, 12, 2024, '2025-01-01', 57000.00, 5700.00),
(9, 12, 2024, '2025-01-01', 66000.00, 6600.00),
(10, 12, 2024, '2025-01-01', 71000.00, 7100.00),
(11, 12, 2024, '2025-01-01', 60000.00, 6000.00),
(12, 12, 2024, '2025-01-01', 77000.00, 7700.00),
(13, 12, 2024, '2025-01-01', 58000.00, 5800.00),
(14, 12, 2024, '2025-01-01', 63000.00, 6300.00),
(15, 12, 2024, '2025-01-01', 72000.00, 7200.00),
(16, 12, 2024, '2025-01-01', 65000.00, 6500.00),
(17, 12, 2024, '2025-01-01', 78000.00, 7800.00),
(18, 12, 2024, '2025-01-01', 56000.00, 5600.00),
(19, 12, 2024, '2025-01-01', 67000.00, 6700.00),
(20, 12, 2024, '2025-01-01', 70000.00, 7000.00);

SELECT * FROM salaries;



-- SALARY DETAILS TABLE (create,insert,display)
CREATE TABLE salary_details (
    id SERIAL PRIMARY KEY,
    salary_id INT REFERENCES salaries(id),
    salary_component_id INT REFERENCES salary_components(id),
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO salary_details (salary_id, salary_component_id, amount)
VALUES 
(1, 1, 30000), (1, 2, 10000), (1, 3, 10000), (1, 4, 5000), (1, 5, 2000), (1, 6, 5000), (1, 7, 2500), (1, 8, 2500),
(2, 1, 35000), (2, 2, 12000), (2, 3, 12000), (2, 4, 6000), (2, 5, 3000), (2, 6, 6000), (2, 7, 3000), (2, 8, 4000),
(3, 1, 25000), (3, 2, 8000), (3, 3, 8000), (3, 4, 4000), (3, 5, 1500), (3, 6, 4000), (3, 7, 2000), (3, 8, 2000),
(4, 1, 32000), (4, 2, 11000), (4, 3, 11000), (4, 4, 5500), (4, 5, 2500), (4, 6, 5500), (4, 7, 2700), (4, 8, 3300);

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



SELECT 
    e.id,
    s.id AS salary_id,
    CONCAT(e.firstname, ' ', e.lastname, ' ', e.surname) AS name,
    s.month,
    s.year,
    s.paid_on,
    s.gross,
    s.deduction,
    s.net,
    s.created_at
FROM salaries s
JOIN employees e ON s.employee_id = e.id
where s.paid_on >= NOW() - INTERVAL '1 MONTH'
ORDER BY e.id ASC;


CREATE TYPE leave_status AS ENUM ('Pending', 'Approved', 'Rejected');

CREATE TABLE leave_requests (
    id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(100),
    leave_type VARCHAR(50),
    from_date DATE,
    to_date DATE,
    days INT,
    reason TEXT,
    applied_on DATE DEFAULT CURRENT_DATE,
    status leave_status DEFAULT 'Pending'
);



INSERT INTO leave_requests (employee_name, department, leave_type, from_date, to_date, days, reason, applied_on, status) VALUES
('Amit Sharma Kumar', 'IT', 'Sick Leave', '2025-04-10', '2025-04-12', 3, 'Fever and cold', '2025-04-07', 'Pending'),
('Sneha Patel Rao', 'HR', 'Casual Leave', '2025-04-15', '2025-04-15', 1, 'Personal work', '2025-04-07', 'Pending'),
('Ravi Verma Singh', 'IT', 'Vacation', '2025-04-20', '2025-04-25', 6, 'Family trip to Goa', '2025-04-06', 'Pending'),
('Vikas Mishra Pandey', 'Sales', 'Sick Leave', '2025-04-08', '2025-04-09', 2, 'Flu symptoms', '2025-04-06', 'Pending'),
('Raj Kapoor Yadav', 'Finance', 'Casual Leave', '2025-04-13', '2025-04-14', 2, 'Home maintenance', '2025-04-07', 'Pending'),
('Megha Joshi Thakur', 'Sales', 'Maternity Leave', '2025-04-01', '2025-06-30', 91, 'Expected delivery', '2025-04-01', 'Pending'),
('Rahul Ghosh Chatterjee', 'IT', 'Sick Leave', '2025-04-11', '2025-04-13', 3, 'Dental surgery recovery', '2025-04-05', 'Pending');


SELECT * FROM leave_requests;


CREATE Table scheme(
    id SERIAL PRIMARY KEY,
    description VARCHAR(25) NOT NULL UNIQUE,
    type INT NOT NULL check(type IN(1,2)),
    code VARCHAR(3) NOT NULL
);

CREATE Table department(
    id SERIAL PRIMARY KEY,
    description VARCHAR(25) NOT NULL UNIQUE,
    type INT NOT NULL check(type IN(1,2,3,4,5))
);




CREATE Table hoa(
    id SERIAL PRIMARY KEY,
    hod INT NOT NULL REFERENCES department(id),
    estScheme INT NOT NULL REFERENCES scheme(id),
    hoa VARCHAR(40) UNIQUE NOT NULL,
    hoa_tier VARCHAR(40) UNIQUE NOT NULL,
    mjH VARCHAR(4) NOT NULL,
    smjH VARCHAR(2) NOT NULL,
    mnH VARCHAR(3) NOT NULL,
    gsH VARCHAR(2) NOT NULL,
    sH VARCHAR(2) NOT NULL,
    dH VARCHAR(3) NOT NULL,
    sdH VARCHAR(3) NOT NULL,
    scheme_code INT REFERENCES scheme(id),
    year VARCHAR(10) NOT NULL,
    amount NUMERIC(10,2) DEFAULT 100.00,
    status VARCHAR(10) NOT NULL
);

INSERT INTO scheme(description,type,code) VALUES
('Establishment', 1, 'NVN'),
('Scheme', 2, 'PVN');

SELECT * FROM scheme;


INSERT INTO department(description,type) VALUES
('Agriculture Dept', 1),
('Education Dept', 2),
('Health Dept', 3),
('Rural Dev. Dept', 4),
('Urban Planning Dept', 5);

SELECT * FROM department;


INSERT INTO hoa (hod, estScheme, hoa, hoa_tier, mjH, smjH, mnH, gsH, sH, dH, sdH, scheme_code, year, amount, status) VALUES
(1, 1, 'Agriculture Infrastructure Dev', '', '1001', '01', '001', '01', '01', '001', '001', 1, '2024-25', 500000.00, 'Active'),
(2, 2, 'Primary Education Expansion', 'District Level', '2002', '02', '002', '02', '02', '002', '002', 2, '2023-24', 250000.50, 'Completed'),
(3, 1, 'National Health Mission - Staff', 'National Level', '3001', '03', '003', '03', '03', '003', '003', 1, '2025-26', 1000000.75, 'Planned'),
(4, 2, 'Rural Road Improvement', 'Block Level', '4002', '04', '004', '04', '04', '004', '004', 2, '2024-25', 750000.00, 'Active'),
(5, 1, 'Urban Development Project - Admin', 'City Level', '5001', '05', '005', '05', '05', '005', '005', 1, '2026-27', 150000.25, 'Pending');

SELECT * FROM hoa;