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

CREATE TABLE airbnb_cleaning_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cleaning_date DATE,
  operation VARCHAR(255),
  affected_rows INT,
  notes TEXT
);

-- Update: make NULL for missing data!
-- Update text columns for empty string ''
UPDATE airbnb_cleaned_data
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

INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-05', "Made missing data NULL", 102599, "Every row was affected, since 'License' was always whitespace. Made sure whitespaces, empty strings and numbers were handled separately.");

/* -- peeking at id duplicates, making sure they occur the way i suspect
with duplicates as (SELECT 
	airbnb_id,
    COUNT(*)
FROM airbnb_cleaned_data
GROUP BY airbnb_id
HAVING COUNT(*) > 1)
select *
from airbnb_cleaned_data a, duplicates b
where a.airbnb_id = b.airbnb_id;

-- showing me the ids with duplicates only
SELECT airbnb_id, COUNT(*)
FROM airbnb_cleaning_sql.airbnb_cleaned_data
GROUP BY airbnb_id
HAVING COUNT(*) > 1;
*/

/* -- This kept timing out, even after changing limited time to 300s, try to find problem
DELETE t1
FROM airbnb_cleaned_data AS t1
INNER JOIN airbnb_cleaned_data AS t2
    ON t1.airbnb_id = t2.airbnb_id
    AND t1.id > t2.id	-- Keep older/lower ID
    WHERE t1.id > 0;	-- ensure safe update mode is satisfied

-- finding locks in MySQL 8.0+
SELECT * FROM performance_schema.metadata_locks 
WHERE OBJECT_SCHEMA = 'airbnb_cleaning_sql';

-- some locks exist, figuring out which ones to kill
SELECT 
    mdl.LOCK_TYPE,
    mdl.LOCK_STATUS,
    mdl.OWNER_THREAD_ID,
    t.PROCESSLIST_ID AS CONNECTION_ID,
    t.PROCESSLIST_USER,
    t.PROCESSLIST_HOST,
    t.PROCESSLIST_COMMAND,
    t.PROCESSLIST_TIME,
    t.PROCESSLIST_INFO AS SQL_TEXT
FROM performance_schema.metadata_locks mdl
JOIN performance_schema.threads t
    ON mdl.OWNER_THREAD_ID = t.THREAD_ID
WHERE mdl.OBJECT_SCHEMA = 'airbnb_cleaning_sql';

-- kill blocked connections
KILL 14;
KILL 15;
KILL 16;
KILL 9;
*/

-- try index creation
CREATE INDEX idx_airbnb_id ON airbnb_cleaned_data(airbnb_id);
CREATE INDEX idx_id ON airbnb_cleaned_data(id);

-- try delete again
DELETE t1
FROM airbnb_cleaned_data AS t1
INNER JOIN airbnb_cleaned_data AS t2
    ON t1.airbnb_id = t2.airbnb_id
    AND t1.id > t2.id	-- Keep older/lower ID
    WHERE t1.id > 0;	-- ensure safe update mode is satisfied

INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-21', "Removed duplicate airbnb_id 's", 541, "Ran into issues with runtime. Started indexing columns that significantly reduce runtime.");

-- Fill host identity verification NULLs
UPDATE airbnb_cleaned_data
SET host_identity_verified = COALESCE(host_identity_verified, 'unconfirmed')
WHERE host_identity_verified IS NULL AND id > 0;

INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Set NULL values in verification to 'unconfirmed'", 289, "Assumed that not having a value for confirmation means 'unconfirmed'.");

-- Set anonymous host names | checked for anonymous names first
-- select * from airbnb_cleaned_data WHERE host_name = 'ANONYMOUS';
UPDATE airbnb_cleaned_data
SET host_name = COALESCE(host_name, 'ANONYMOUS')
WHERE host_name IS NULL AND id > 0;

INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Gave NULL values in host_name the 'ANONYMOUS' tag", 404, "Checked for ANONYMOUS existing. Does not exist and is now used as new tag for empty names.");

-- Set unknown airbnb names | checked for unknown names first
-- select * from airbnb_cleaned_data WHERE airbnb_name = 'UNKNOWN';
UPDATE airbnb_cleaned_data
SET airbnb_name = COALESCE(airbnb_name, 'UNKNOWN')
WHERE airbnb_name IS NULL AND id > 0;

INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Gave NULL values in airbnb_name the 'UNKNOWN' tag", 249, "Checked for UNKNOWN existing. Does not exist and is now used as new tag for empty names.");

-- NEXT CLEANING STEPS:
-- geo data: lat/long, neighbourhood, country etc etc.
    
-- INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
-- VALUES ('2025-02-22', "Gave NULL values in host_name the 'ANONYMOUS' tag", 404, "Checked for ANONYMOUS existing. Does not exist and is now used as new tag for empty names.");

select * from airbnb_cleaning_log;
select * from airbnb_cleaned_data;