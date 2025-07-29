-- Create raw staging table
CREATE TABLE 12_airbnb_open_data.airbnb_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    airbnb_id VARCHAR(255),
    NAME VARCHAR(500),
    host_id VARCHAR(255),
    host_identity_verified VARCHAR(255),
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    lat VARCHAR(255),
    `long` VARCHAR(255),
    country VARCHAR(255),
    country_code VARCHAR(255),
    instant_bookable VARCHAR(255),
    cancellation_policy VARCHAR(255),
    room_type VARCHAR(255),
    Construction_year VARCHAR(255),
    price VARCHAR(255),
    service_fee VARCHAR(255),
    minimum_nights VARCHAR(255),
    number_of_reviews VARCHAR(255),
    last_review VARCHAR(255),
    reviews_per_month VARCHAR(255),
    review_rate_number VARCHAR(255),
    calculated_host_listings_count VARCHAR(255),
    availability_365 VARCHAR(255),
    house_rules TEXT,
    license VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/12_airbnb_open_data/0_Raw/Airbnb_Open_Data.csv'
INTO TABLE 12_airbnb_open_data.airbnb_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(airbnb_id, NAME, host_id, host_identity_verified, host_name, neighbourhood_group, neighbourhood, lat, `long`, country, country_code, instant_bookable, cancellation_policy, room_type, Construction_year, price, service_fee, minimum_nights, number_of_reviews, last_review, reviews_per_month, review_rate_number, calculated_host_listings_count, availability_365, house_rules, license);

-- Create cleaning table
CREATE TABLE 12_airbnb_open_data.airbnb_cleaned_data LIKE 12_airbnb_open_data.airbnb_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 12_airbnb_open_data.airbnb_cleaned_data
SELECT * FROM 12_airbnb_open_data.airbnb_raw_data_staging;

-- Create log table
CREATE TABLE 12_airbnb_open_data.airbnb_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 12_airbnb_open_data.airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 102599, 'Created staging, cleaning and logging tables.');