-- Create raw staging table
CREATE TABLE 03_data_science_salaries_2023.ds_salaries_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    work_year VARCHAR(255),
    experience_level VARCHAR(255),
    employment_type VARCHAR(255),
    job_title VARCHAR(255),
    salary VARCHAR(255),
    salary_currency VARCHAR(255),
    salary_in_usd VARCHAR(255),
    employee_residence VARCHAR(255),
    remote_ratio VARCHAR(255),
    company_location VARCHAR(255),
    company_size VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/03_data_science_salaries_2023/0_Raw/ds_salaries.csv'
INTO TABLE 03_data_science_salaries_2023.ds_salaries_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(work_year, experience_level, employment_type, job_title, salary, salary_currency, salary_in_usd, employee_residence, remote_ratio, company_location, company_size);

-- Create cleaning table
CREATE TABLE 03_data_science_salaries_2023.ds_salaries_cleaned_data LIKE 03_data_science_salaries_2023.ds_salaries_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 03_data_science_salaries_2023.ds_salaries_cleaned_data
SELECT * FROM 03_data_science_salaries_2023.ds_salaries_raw_data_staging;

-- Create log table
CREATE TABLE 03_data_science_salaries_2023.ds_salaries_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 03_data_science_salaries_2023.ds_salaries_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-06-30', 'Table creation', 3755, 'Created staging, cleaning and logging tables.');