CREATE TABLE airbnb_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    airbnb_id BIGINT,
    airbnb_name VARCHAR(255),
    hostid BIGINT,
    host_identity_verified VARCHAR(255),
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    geo_lat VARCHAR(255),
    geo_long VARCHAR(255),
    country VARCHAR(255),
    country_code VARCHAR(255),
    instant_bookable VARCHAR(255),
    cancellation_policy VARCHAR(255),
    room_type VARCHAR(255),
    construction_year VARCHAR(255),
    price VARCHAR(255),
    service_fee VARCHAR(255),
    minimum_nights VARCHAR(255),
    number_of_reviews VARCHAR(255),
    last_review VARCHAR(255),
    reviews_per_month VARCHAR(255),
    review_rate_number VARCHAR(255),
    calculated_host_listings_count VARCHAR(255),
    availability_365 VARCHAR(255),
    house_rules TEXT NULL,
    license VARCHAR(255)
    -- Define all columns as nullable initially

    );
    
    /*
-- Checked local permissions to identify file location

SHOW VARIABLES LIKE 'secure_file_priv';

*/

    /*
-- Function: Grab all column names without ID; Since we use primary key and therefor there's a column mismatch

SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'airbnb_raw_data_staging'
  AND TABLE_SCHEMA = 'airbnb_cleaning_sql'
  AND COLUMN_NAME != 'id';
  
*/

-- Importing data with INFILE instead of import wizard. Since data is NOT clean and very large

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/0.1.12_airbnb_open_data/Airbnb_Open_Data.csv'
INTO TABLE airbnb_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(airbnb_id,airbnb_name,hostid,host_identity_verified,host_name,neighbourhood_group,neighbourhood,geo_lat,geo_long,country,country_code,instant_bookable,cancellation_policy,room_type,construction_year,price,service_fee,minimum_nights,number_of_reviews,last_review,reviews_per_month,review_rate_number,calculated_host_listings_count,availability_365,house_rules,license
);