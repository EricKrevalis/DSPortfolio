-- make second table which we will use to clean
CREATE TABLE airbnb_cleaned_data (
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
INSERT INTO airbnb_cleaned_data
SELECT * FROM airbnb_raw_data_staging;

-- Update: make NULL for missing data!
-- Update text columns for empty string ''
UPDATE airbnb_cleaning_sql.airbnb_cleaned_data
SET 
    airbnb_id = CASE WHEN airbnb_id IS NULL OR airbnb_id = 0 THEN NULL ELSE airbnb_id END, -- Update numeric column differently
    airbnb_name = NULLIF(airbnb_name, ''),
    hostid = CASE WHEN hostid IS NULL OR hostid = 0 THEN NULL ELSE hostid END, -- Update numeric column differently
    host_identity_verified = NULLIF(host_identity_verified, ''),
    host_name = NULLIF(host_name, ''),
    neighbourhood_group = NULLIF(neighbourhood_group, ''),
    neighbourhood = NULLIF(neighbourhood, ''),
    geo_lat = NULLIF(geo_lat, ''),
    geo_long = NULLIF(geo_long, ''),
    country = NULLIF(country, ''),
    country_code = NULLIF(country_code, ''),
    instant_bookable = NULLIF(instant_bookable, ''),
    cancellation_policy  = NULLIF(cancellation_policy, ''),
    room_type = NULLIF(room_type, ''),
    construction_year = NULLIF(construction_year, ''),
    price = NULLIF(price, ''),
    service_fee = NULLIF(service_fee, ''),
    minimum_nights = NULLIF(minimum_nights, ''),
    number_of_reviews = NULLIF(number_of_reviews, ''),
    last_review = NULLIF(last_review, ''),
    reviews_per_month = NULLIF(reviews_per_month, ''),
    review_rate_number = NULLIF(review_rate_number, ''),
    calculated_host_listings_count = NULLIF(calculated_host_listings_count, ''),
    availability_365 = NULLIF(availability_365, ''),
    house_rules = NULLIF(house_rules, ''),
    license = NULLIF(REGEXP_REPLACE(license, '[^[:print:]]', ''), '') -- update license, making non-printable characters NULL
	WHERE id > 0; -- Use the primary key to satisfy safe update mode

select * from airbnb_cleaned_data;

/*
-- peeking at id duplicates, making sure they occur the way i suspect
with duplicates as (SELECT 
	airbnb_id,
    COUNT(*)
FROM airbnb_raw_data_staging
GROUP BY airbnb_id
HAVING COUNT(*) > 1)
select *
from airbnb_raw_data_staging a, duplicates b
where a.airbnb_id = b.airbnb_id;
*/
    
-- SELECT * from airbnb_raw_data_staging
-- where geo_lat is null or geo_lat = '';


-- Drop rows with missing critical fields (e.g., location)
-- DELETE FROM airbnb_raw_data_staging
-- WHERE geo_lat IS NULL OR geo_long IS NULL;

-- Replace missing `host_name` with 'Unknown'
-- UPDATE airbnb_raw_data_staging
-- SET host_name = 'Unknown'
-- WHERE host_name IS NULL OR host_name = '';