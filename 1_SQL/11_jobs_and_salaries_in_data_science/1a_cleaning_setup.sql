-- Create raw staging table
CREATE TABLE 11_jobs_and_salaries_in_data_science.jobs_ds_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    work_year VARCHAR(255),
    job_title VARCHAR(255),
    job_category VARCHAR(255),
    salary_currency VARCHAR(255),
    salary VARCHAR(255),
    salary_in_usd VARCHAR(255),
    employee_residence VARCHAR(255),
    experience_level VARCHAR(255),
    employment_type VARCHAR(255),
    work_setting VARCHAR(255),
    company_location VARCHAR(255),
    company_size VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/11_jobs_and_salaries_in_data_science/0_Raw/jobs_in_data.csv'
INTO TABLE 11_jobs_and_salaries_in_data_science.jobs_ds_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(work_year, job_title, job_category, salary_currency, salary, salary_in_usd, employee_residence, experience_level, employment_type, work_setting, company_location, company_size);

-- Create cleaning table
CREATE TABLE 11_jobs_and_salaries_in_data_science.jobs_ds_cleaned_data LIKE 11_jobs_and_salaries_in_data_science.jobs_ds_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 11_jobs_and_salaries_in_data_science.jobs_ds_cleaned_data
SELECT * FROM 11_jobs_and_salaries_in_data_science.jobs_ds_raw_data_staging;

-- Create log table
CREATE TABLE 11_jobs_and_salaries_in_data_science.jobs_ds_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 11_jobs_and_salaries_in_data_science.jobs_ds_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 9355, 'Created staging, cleaning and logging tables.');