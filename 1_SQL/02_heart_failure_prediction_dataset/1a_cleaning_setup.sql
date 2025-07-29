-- create first base table setup, define all columns as nullable initially (or able to have empty strings)
-- Create raw staging table
CREATE TABLE 02_heart_failure_prediction_dataset.heart_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Age VARCHAR(255),
    Sex VARCHAR(255),
    ChestPainType VARCHAR(255),
    RestingBP VARCHAR(255),
    Cholesterol VARCHAR(255),
    FastingBS VARCHAR(255),
    RestingECG VARCHAR(255),
    MaxHR VARCHAR(255),
    ExerciseAngina VARCHAR(255),
    Oldpeak VARCHAR(255),
    ST_Slope VARCHAR(255),
    HeartDisease VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/02_heart_failure_prediction_dataset/0_Raw/heart.csv'
INTO TABLE 02_heart_failure_prediction_dataset.heart_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Age, Sex, ChestPainType, RestingBP, Cholesterol, FastingBS, RestingECG, MaxHR, ExerciseAngina, Oldpeak, ST_Slope, HeartDisease);

-- Create cleaning table
CREATE TABLE 02_heart_failure_prediction_dataset.heart_cleaned_data LIKE 02_heart_failure_prediction_dataset.heart_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 02_heart_failure_prediction_dataset.heart_cleaned_data
SELECT * FROM 02_heart_failure_prediction_dataset.heart_raw_data_staging;

-- Create log table
CREATE TABLE 02_heart_failure_prediction_dataset.heart_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 02_heart_failure_prediction_dataset.heart_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-06-30', 'Table creation', 918, 'Created staging, cleaning and logging tables.');