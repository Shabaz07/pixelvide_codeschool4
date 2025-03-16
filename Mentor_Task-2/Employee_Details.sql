--CREATE DB
CREATE DATABASE Employee_Details;


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
    description VARCHAR(100) NOT NULL UNIQUE
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
('Hyderabad'), ('Bangalore'), ('Mumbai'), ('Chennai'), ('Pune'), ('Delhi');

SELECT * FROM location;


-- EMPLOYEES TABLE (create,insert,display)
CREATE Table employees(
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(100) NOT NUll,
    lastName VARCHAR(100) NOT NUll,    
    surname VARCHAR(100) NOT NULL,
    doj DATE NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10) CHECK(gender = 'Male' or gender = 'Female' or gender = 'Others') NOT NULL,
    phone VARCHAR(10) NOT NULL UNIQUE,
    working_status_id INT REFERENCES working_status(id) NOT NULL,
    designation_id INT REFERENCES designations(id) NOT NULL,
    location_id INT REFERENCES location(id) NOT NULL,
    gross NUMERIC(10,2) NOT NULL CHECK(gross >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees (firstName, lastName, surname, doj, dob, gender, phone, working_status_id, designation_id, location_id, gross)
VALUES
('Amit', 'Sharma', 'Kumar', '2018-06-15', '1990-02-10', 'Male', '9876543201', 1, 1, 1, 75000),
('Sneha', 'Patel', 'Rao', '2019-07-10', '1992-05-14', 'Female', '9876543202', 1, 2, 2, 90000),
('Ravi', 'Verma', 'Singh', '2020-09-20', '1993-08-25', 'Male', '9876543203', 1, 3, 3, 60000),
('Priya', 'Iyer', 'Nair', '2017-11-30', '1991-12-05', 'Female', '9876543204', 1, 4, 4, 85000),
('Vikas', 'Mishra', 'Pandey', '2021-03-12', '1995-09-18', 'Male', '9876543205', 2, 5, 5, 70000),
('Raj', 'Kapoor', 'Yadav', '2015-08-10', '1988-07-30', 'Male', '9876543206', 3, 2, 6, 50000),
('Sunita', 'Das', 'Roy', '2016-05-22', '1989-06-21', 'Female', '9876543207', 3, 1, 1, 65000),
('Arjun', 'Reddy', 'Gowda', '2019-04-15', '1994-11-17', 'Male', '9876543208', 4, 3, 2, 58000),
('Megha', 'Joshi', 'Thakur', '2018-10-05', '1990-01-29', 'Female', '9876543209', 1, 5, 3, 72000),
('Rahul', 'Ghosh', 'Chatterjee', '2020-12-20', '1996-03-05', 'Male', '9876543210', 1, 1, 4, 80000),
('Ananya', 'Shetty', 'Pillai', '2019-07-14', '1993-09-10', 'Female', '9876543211', 1, 4, 5, 76000),
('Manoj', 'Tripathi', 'Shukla', '2021-02-20', '1995-11-20', 'Male', '9876543212', 1, 2, 6, 67000),
('Sangeeta', 'Yadav', 'Gupta', '2016-09-12', '1987-07-25', 'Female', '9876543213', 3, 5, 1, 72000),
('Rohan', 'Naidu', 'Krishna', '2017-05-06', '1989-05-14', 'Male', '9876543214', 1, 3, 2, 79000),
('Neha', 'Bose', 'Sen', '2019-12-22', '1994-04-08', 'Female', '9876543215', 1, 1, 3, 73000),
('Arvind', 'Kumar', 'Jha', '2018-08-18', '1990-08-30', 'Male', '9876543216', 1, 4, 4, 87000),
('Divya', 'Nair', 'Menon', '2020-03-17', '1992-10-10', 'Female', '9876543217', 2, 2, 5, 69000),
('Siddharth', 'Pandey', 'Sharma', '2015-11-25', '1986-12-15', 'Male', '9876543218', 3, 3, 6, 60000),
('Pooja', 'Rathore', 'Chauhan', '2019-06-30', '1991-06-05', 'Female', '9876543219', 1, 5, 1, 74000),
('Kunal', 'Singh', 'Rajput', '2017-04-22', '1988-02-28', 'Male', '9876543220', 1, 2, 2, 77000);

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

-- QUERIES
--(1)list of employees (name, doj, dob, gender, phone, working_status, designation, location)
SELECT concat(e.firstname,' ',e.lastname,' ',e.surname) name,e.doj,e.dob,e.gender,e.phone,ws.description,d.description,l.district
FROM employees e 
JOIN working_status ws on e.working_status_id = ws.id 
JOIN designations d on d.id = e.designation_id
JOIN location l on l.id = e.location_id

--(2)count of employees in location wise(location,employee count)
SELECT  l.district location,count(e.id) employee_count
FROM location l 
LEFT JOIN employees e on l.id = e.location_id
GROUP BY l.district

--(3)count of employees in designation wise (designation,employee count)
SELECT d.description designation,count(e.id) employee_count
FROM designations d 
LEFT JOIN employees e on d.id = e.designation_id
GROUP BY d.description
ORDER BY d.description

--(4)count of employees in working status (working status,employee count)
SELECT ws.description,count(e.id) employee_count
FROM working_status ws 
LEFT JOIN employees e on ws.id = e.designation_id
GROUP BY ws.description
ORDER BY ws.description


--(5)employees retirement date (employee_id, employee_name, dob, doj, retirement_date)
SELECT id,concat(firstname,' ',lastname,' ',surname) Employee_name,dob,doj,(dob + INTERVAL '60 years') retirement_date
FROM employees

--(6)salary received by each employee for last month (employee_id, name, salary_year, salary_month, gross, deduction, net).
SELECT e.id,concat(e.firstname,' ',e.lastname,' ',e.surname) Employee_name,s.year,s.month,s.gross,s.deduction,s.net
FROM employees e 
JOIN salaries s ON s.employee_id = e.id 
where (s.year, s.month) = (SELECT year,month FROM salaries ORDER BY year desc, month desc LIMIT 1)
--also we can do like this
SELECT e.id,CONCAT(e.firstname, ' ', e.lastname,' ',e.surname) name,s.year AS salary_year, s.month AS salary_month, s.gross, s.deduction, s.net
FROM employees e
JOIN salaries s ON e.id = s.employee_id
WHERE s.paid_on >= NOW() - INTERVAL '1 MONTH'
ORDER BY e.id;

--(7)maximum, minimum salary of employee, average salary of employees.
SELECT MAX(s.net) max_salary,MIN(s.net) min_salary,AVG(s.net) avg_salary
FROM salaries s;

--(8)show salary break up(each salary components) of each employee wise.
SELECT e.id employee_id,concat(e.firstname,' ',e.lastname,' ',e.surname) name,s.year,s.month,sc.description salary_component, sd.amount
FROM employees e
JOIN salaries s ON e.id = s.employee_id
JOIN salary_details sd ON s.id = sd.salary_id
JOIN salary_components sc ON sd.salary_component_id = sc.id
ORDER BY e.id, s.year, s.month, sc.description;

--(9)list of emp who have not received salary for last month.
SELECT e.id,CONCAT(e.firstname, ' ', e.lastname,' ',e.surname) name
FROM employees e
WHERE e.id NOT IN (SELECT s.employee_id from salaries s WHERE s.paid_on >= NOW() - INTERVAL '1 MONTH')
ORDER BY e.id;
