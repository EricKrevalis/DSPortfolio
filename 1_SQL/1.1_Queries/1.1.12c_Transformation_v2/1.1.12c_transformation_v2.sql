-- create table to transform data in, if necessary
-- CREATE TABLE airbnb_transformed_data_v2 LIKE airbnb_cleaned_data_transformable;
-- INSERT INTO airbnb_transformed_data_v2 SELECT * FROM airbnb_cleaned_data_transformable;
-- create transformation log file
CREATE TABLE airbnb_transformation_log_v2 LIKE airbnb_cleaning_log;
-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_cleaned_data_transformable", 69352, "Use the previously created table to transform data into new insights.");

-- transf. #1
CREATE TABLE airbnb_transformation_v2_policy_price AS
SELECT 
    cancellation_policy,
    AVG(price_$) AS avg_price,
    AVG(availability_365) AS avg_availability,
    AVG(number_of_reviews) AS avg_reviews
FROM airbnb_cleaned_data_transformable
GROUP BY cancellation_policy;

-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v2_policy_price", 3, "Created first transformed table, checking correlation: cancellation_policy - airbnb-performance");

-- transf. #2
CREATE TABLE airbnb_transformation_v2_policy_bookable_price AS
SELECT 
    cancellation_policy,
    instant_bookable,
    AVG(price_$ + service_fee_$) AS avg_total_cost
FROM airbnb_cleaned_data_transformable
GROUP BY cancellation_policy, instant_bookable;

-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v2_policy_bookable_price", 6, "Created second transformed table, checking correlation: cancellation_policy - instant_bookable");

-- transf. #3
CREATE TABLE airbnb_transformation_v2_policy_rules AS
SELECT 
    cancellation_policy,
    AVG(length(house_rules)) AS avg_rule_complexity
FROM airbnb_cleaned_data_transformable
GROUP BY cancellation_policy;

-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v2_policy_rules", 3, "Created third transformed table, checking correlation: cancellation_policy - house_rules");

-- transf. #4
CREATE TABLE airbnb_transformation_v2_policy_location AS
SELECT 
    cancellation_policy,
    neighbourhood_group,
    COUNT(*) as total_listings
FROM airbnb_cleaned_data_transformable
GROUP BY cancellation_policy,  neighbourhood_group;

-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "airbnb_transformation_v2_policy_location", 15, "Created fourth transformed table, checking correlation: cancellation_policy - location");

-- log changes
INSERT INTO airbnb_transformation_log_v2 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-03-03', "Transformation Results", 0, "No correlations found between observed data and cancellation policies.");