-- Create raw staging table
CREATE TABLE 07_emergency_911_calls.emergency_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lat VARCHAR(255),
    lng VARCHAR(255),
    `desc` VARCHAR(255),
    zip VARCHAR(255),
    title VARCHAR(255),
    timeStamp VARCHAR(255),
    twp VARCHAR(255),
    addr VARCHAR(255),
    e VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/07_emergency_-_911_calls/0_Raw/911.csv'
INTO TABLE 07_emergency_911_calls.emergency_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(lat, lng, `desc`, zip, title, timeStamp, twp, addr, e);

-- Create cleaning table
CREATE TABLE 07_emergency_911_calls.emergency_cleaned_data LIKE 07_emergency_911_calls.emergency_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 07_emergency_911_calls.emergency_cleaned_data
SELECT * FROM 07_emergency_911_calls.emergency_raw_data_staging;

-- Create log table
CREATE TABLE 07_emergency_911_calls.emergency_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 07_emergency_911_calls.emergency_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 663522, 'Created staging, cleaning and logging tables.');