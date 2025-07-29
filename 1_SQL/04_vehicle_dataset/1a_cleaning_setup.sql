-- Create raw staging table
CREATE TABLE 04_vehicle_dataset.vehicle_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Make VARCHAR(255),
    Model VARCHAR(255),
    Price VARCHAR(255),
    Year VARCHAR(255),
    Kilometer VARCHAR(255),
    Fuel_Type VARCHAR(255),
    Transmission VARCHAR(255),
    Location VARCHAR(255),
    Color VARCHAR(255),
    Owner VARCHAR(255),
    Seller_Type VARCHAR(255),
    Engine VARCHAR(255),
    Max_Power VARCHAR(255),
    Max_Torque VARCHAR(255),
    Drivetrain VARCHAR(255),
    Length VARCHAR(255),
    Width VARCHAR(255),
    Height VARCHAR(255),
    Seating_Capacity VARCHAR(255),
    Fuel_Tank_Capacity VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/04_vehicle_dataset/0_Raw/car details v4.csv'
INTO TABLE 04_vehicle_dataset.vehicle_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Make, Model, Price, Year, Kilometer, Fuel_Type, Transmission, Location, Color, Owner, Seller_Type, Engine, Max_Power, Max_Torque, Drivetrain, Length, Width, Height, Seating_Capacity, Fuel_Tank_Capacity);

-- Create cleaning table
CREATE TABLE 04_vehicle_dataset.vehicle_cleaned_data LIKE 04_vehicle_dataset.vehicle_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 04_vehicle_dataset.vehicle_cleaned_data
SELECT * FROM 04_vehicle_dataset.vehicle_raw_data_staging;

-- Create log table
CREATE TABLE 04_vehicle_dataset.vehicle_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 04_vehicle_dataset.vehicle_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 2059, 'Created staging, cleaning and logging tables.');