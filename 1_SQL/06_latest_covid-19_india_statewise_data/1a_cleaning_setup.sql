-- Create raw staging table
CREATE TABLE 06_latest_covid_19_india_statewise_data.covid_india_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    State_UTs VARCHAR(255),
    Total_Cases VARCHAR(255),
    Active VARCHAR(255),
    Discharged VARCHAR(255),
    Deaths VARCHAR(255),
    Active_Ratio VARCHAR(255),
    Discharge_Ratio VARCHAR(255),
    Death_Ratio VARCHAR(255),
    Population VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/06_latest_covid-19_india_statewise_data/0_Raw/Latest Covid-19 India Status.csv'
INTO TABLE 06_latest_covid_19_india_statewise_data.covid_india_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(State_UTs, Total_Cases, Active, Discharged, Deaths, Active_Ratio, Discharge_Ratio, Death_Ratio, Population);

-- Create cleaning table
CREATE TABLE 06_latest_covid_19_india_statewise_data.covid_india_cleaned_data LIKE 06_latest_covid_19_india_statewise_data.covid_india_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 06_latest_covid_19_india_statewise_data.covid_india_cleaned_data
SELECT * FROM 06_latest_covid_19_india_statewise_data.covid_india_raw_data_staging;

-- Create log table
CREATE TABLE 06_latest_covid_19_india_statewise_data.covid_india_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 06_latest_covid_19_india_statewise_data.covid_india_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 36, 'Created staging, cleaning and logging tables.');