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

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-05', "Made missing data NULL", 102599, "Every row was affected, since 'License' was always whitespace. Made sure whitespaces, empty strings and numbers were handled separately.");

-- try index creation, since initial approach timed out
CREATE INDEX idx_airbnb_id ON airbnb_cleaned_data(airbnb_id);
CREATE INDEX idx_id ON airbnb_cleaned_data(id);

-- try deleting airbnb_id duplicates again
DELETE t1
FROM airbnb_cleaned_data AS t1
INNER JOIN airbnb_cleaned_data AS t2
    ON t1.airbnb_id = t2.airbnb_id
    AND t1.id > t2.id	-- Keep older/lower ID
    WHERE t1.id > 0;	-- ensure safe update mode is satisfied

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-21', "Removed duplicate airbnb_id 's", 541, "Ran into issues with runtime. Started indexing columns that significantly reduce runtime.");

-- Fill host identity verification NULLs
UPDATE airbnb_cleaned_data
SET host_identity_verified = COALESCE(host_identity_verified, 'unconfirmed')
WHERE host_identity_verified IS NULL AND id > 0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Set NULL values in verification to 'unconfirmed'", 289, "Assumed that not having a value for confirmation means 'unconfirmed'.");

-- Set anonymous host names | checked for anonymous names first
-- select * from airbnb_cleaned_data WHERE host_name = 'ANONYMOUS';
UPDATE airbnb_cleaned_data
SET host_name = COALESCE(host_name, 'ANONYMOUS')
WHERE host_name IS NULL AND id > 0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Gave NULL values in host_name the 'ANONYMOUS' tag", 404, "Checked for ANONYMOUS existing. Does not exist and is now used as new tag for empty names.");

-- Set unknown airbnb names | checked for unknown names first
-- select * from airbnb_cleaned_data WHERE airbnb_name = 'UNKNOWN';
UPDATE airbnb_cleaned_data
SET airbnb_name = COALESCE(airbnb_name, 'UNKNOWN')
WHERE airbnb_name IS NULL AND id > 0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Gave NULL values in airbnb_name the 'UNKNOWN' tag", 249, "Checked for UNKNOWN existing. Does not exist and is now used as new tag for empty names.");

-- remove faulty neighbourhood_group names
UPDATE airbnb_cleaned_data
SET neighbourhood_group = 'Manhattan'
WHERE neighbourhood_group = 'manhatan' AND id>0;
UPDATE airbnb_cleaned_data
SET neighbourhood_group = 'Brooklyn'
WHERE neighbourhood_group = 'brookln' AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Fixed incorrect neighbourhood_group names 'manhatan' and 'brookln'.", 2, "Part of helping the process to infer neighbourhood/neighbourhood_group.");

-- fix NULL neighbourhood: associate to a neighbourhood group, inferred by most common correlation
CREATE TEMPORARY TABLE neighbourhood_lookup AS
SELECT 
    neighbourhood,
    neighbourhood_group,
    COUNT(*) AS count
FROM airbnb_cleaned_data
WHERE neighbourhood_group IS NOT NULL
GROUP BY neighbourhood, neighbourhood_group
ORDER BY neighbourhood, count DESC;

-- create index due to join being resource intensive
CREATE INDEX idx_neighbourhood ON airbnb_cleaned_data(neighbourhood);

UPDATE airbnb_cleaned_data a
	JOIN neighbourhood_lookup b ON a.neighbourhood=b.neighbourhood
	SET a.neighbourhood_group = b.neighbourhood_group
	WHERE a.neighbourhood_group IS NULL AND a.id>0;
    
-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Inferred neighbourhood_group NULL values.", 29, "Used neighbourhood to associate groups, checked for duplicates, none existed so this works cleanly.");

-- fill in NULL country/country_code
-- create ISO country reference table
CREATE TEMPORARY TABLE iso_countries (
    country VARCHAR(100),
    country_code CHAR(2)
);

-- examplary tables, these are technically not needed since everything is United States/US, but I want to fill this in anyway
INSERT INTO iso_countries VALUES
('United States', 'US'),
('Canada', 'CA'),
('United Kingdom', 'GB'),
('Australia', 'AU')
;

-- index country and countrycode, since we're using join operation on 100k+ rows again
CREATE INDEX idx_country_code ON airbnb_cleaned_data(country_code);
CREATE INDEX idx_country ON airbnb_cleaned_data(country);

-- fill in the associated country and country codes
UPDATE airbnb_cleaned_data a
JOIN iso_countries c ON 
    a.country = c.country OR 
    a.country_code = c.country_code
SET 
    a.country = COALESCE(a.country, c.country),
    a.country_code = COALESCE(a.country_code, c.country_code)
WHERE a.country IS NULL AND a.id>0
	OR a.country_code IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Inferred country_code and country to fill NULL values", 487, "Created temporary table to associate country->country_code and country_code->country.");

-- remove "unsafe" entries, determined by unconfirmed host identity AND non-existent geolocation
DELETE
FROM airbnb_cleaned_data
WHERE host_identity_verified='unconfirmed' AND geo_lat IS NULL AND id>0
	OR host_identity_verified='unconfirmed' AND geo_long IS NULL AND id>0;
    
-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-22', "Removed 'unsafe' entries.", 5, "Assumed that unconfirmed host AND no geo location is not a safe airbnb entry.");

-- NEXT CLEANING STEPS:
-- geo data: lat/long, neighbourhood, country etc etc.