-- create table to transform data in, if necessary
-- CREATE TABLE airbnb_transformed_data_v1 LIKE airbnb_cleaned_data_transformable;
-- INSERT INTO airbnb_transformed_data_v1 SELECT * FROM airbnb_cleaned_data_transformable;
-- create transformation log file
CREATE TABLE airbnb_transformation_log_v1 LIKE airbnb_cleaning_log;
-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "airbnb_cleaned_data_transformable", 69352, "Use the previously created table to transform data into new insights.");

-- transf. #1
CREATE TABLE airbnb_transformation_v1_host_price AS
SELECT 
    host_identity_verified,
    AVG(number_of_reviews) AS avg_reviews,
    AVG(price_$) AS avg_price,
    AVG(service_fee_$) AS avg_service_fee,
    AVG(availability_365) AS avg_annual_availability,
    AVG(review_rate_number) AS avg_rating
FROM airbnb_cleaned_data_transformable
GROUP BY host_identity_verified;

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v1_host_price", 2, "Created first transformed table, checking correlation: host_identity_verified - airbnb-performance");

-- transf. #2
CREATE TABLE airbnb_transformation_v1_host_roomtype AS
SELECT 
    host_identity_verified,
    room_type,
    AVG(price_$) AS avg_price,
    COUNT(*) AS total_listings
FROM airbnb_cleaned_data_transformable
GROUP BY host_identity_verified, room_type;

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v1_host_roomtype", 8, "Created second transformed table, checking correlation: host_identity_verified - room-type");

-- transf. #3
CREATE TABLE airbnb_transformation_v1_host_neighbourhood AS
SELECT 
    host_identity_verified,
    neighbourhood_group,
    COUNT(*) AS total_listings
FROM airbnb_cleaned_data_transformable
GROUP BY host_identity_verified, neighbourhood_group;

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v1_host_neighbourhood", 10, "Created third transformed table, checking correlation: host_identity_verified - location");

-- transf. #4
CREATE TABLE airbnb_transformation_v1_host_policy AS
SELECT 
    host_identity_verified,
    cancellation_policy,
    COUNT(*) AS total_listings
FROM airbnb_cleaned_data_transformable
GROUP BY host_identity_verified, cancellation_policy;

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v1_host_policy", 6, "Created fourth transformed table, checking correlation: host_identity_verified - cancellation_policy");

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "Transformation Results", 0, "No correlations found between observed data and host's verified/unconfirmed identity.");

-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-15', "Transformation Results Addendum", 0, "Slight correlations visible only in verification - room_type metric. Around 7.2% increase in price for verified hotel rooms, and around 2.7% increase in price for unverified shared rooms.");