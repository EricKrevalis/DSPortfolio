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

-- Temporary table with neighborhood centroids
CREATE TEMPORARY TABLE neighborhood_geo_ref AS
SELECT 
    neighbourhood,
    country,
    country_code,
    AVG(geo_lat) AS avg_lat,
    AVG(geo_long) AS avg_long,
    COUNT(*) AS listings_count
FROM airbnb_cleaned_data
WHERE 
    neighbourhood IS NOT NULL AND
    geo_lat IS NOT NULL AND
    geo_long IS NOT NULL
GROUP BY neighbourhood, country, country_code;

-- Update missing neighborhood data using spatial proximity
UPDATE airbnb_cleaned_data a
JOIN (
    SELECT 
        a.id,
        r.neighbourhood,
        r.country,
        r.country_code,
        ROW_NUMBER() OVER (
            PARTITION BY a.id 
            ORDER BY 
                (POWER(a.geo_lat - r.avg_lat, 2) + 
                 POWER(a.geo_long - r.avg_long, 2)) *
                (1 / LOG(r.listings_count + 1)) -- Weight by neighborhood size
        ) AS proximity_rank
    FROM airbnb_cleaned_data a
    JOIN neighborhood_geo_ref r
    WHERE 
        a.neighbourhood IS NULL AND
        a.geo_lat IS NOT NULL AND
        a.geo_long IS NOT NULL
) b ON a.id = b.id AND b.proximity_rank = 1
SET 
    a.neighbourhood = b.neighbourhood,
    a.country = b.country,
    a.country_code = b.country_code;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "Filled in neighbourhoods by using geolocations.", 16, "Used weighted function to find closest geolocation depending on average geolocation.");

-- Create temporary lookup table to identify which neighbourhood_group is in which country
CREATE TEMPORARY TABLE neighbourhood_group_country AS
SELECT 
    neighbourhood_group,
    MAX(country) AS country, -- Most frequent country
    MAX(country_code) AS country_code -- Most frequent code
FROM (
    SELECT 
        neighbourhood_group,
        country,
        country_code,
        ROW_NUMBER() OVER (
            PARTITION BY neighbourhood_group 
            ORDER BY COUNT(*) DESC
        ) AS freq_rank
    FROM airbnb_cleaned_data
    WHERE country IS NOT NULL AND country_code IS NOT NULL
    GROUP BY neighbourhood_group, country, country_code
) ranked
WHERE freq_rank = 1
GROUP BY neighbourhood_group;

-- add missing values on country/country_code based off of neighbourhood
UPDATE airbnb_cleaned_data a
JOIN neighbourhood_group_country b 
    ON a.neighbourhood_group = b.neighbourhood_group
SET 
    a.country = COALESCE(a.country, b.country),
    a.country_code = COALESCE(a.country_code, b.country_code)
WHERE a.country IS NULL OR a.country_code IS NULL;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "Filled in country and country_code NULLs", 90, "Although technically unnecessary, used neighbourhood_group to identify correlating country.");

-- avg geo location for the 3 entries that have missing geolocation
CREATE TEMPORARY TABLE neighbourhood_geo_avg AS
SELECT 
    neighbourhood,
    AVG(geo_lat) AS avg_lat,
    AVG(geo_long) AS avg_long
FROM airbnb_cleaned_data
WHERE 
    neighbourhood IS NOT NULL AND
    geo_lat IS NOT NULL AND
    geo_long IS NOT NULL
GROUP BY neighbourhood, country, country_code;

-- update missing geolocations
UPDATE airbnb_cleaned_data a
JOIN neighbourhood_geo_avg g
    ON a.neighbourhood = g.neighbourhood
SET 
    a.geo_lat = COALESCE(a.geo_lat, g.avg_lat),
    a.geo_long = COALESCE(a.geo_long, g.avg_long)
WHERE a.geo_long IS NULL AND a.id>0 OR a.geo_lat IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "Filled in missing geolocation on safe entries.", 3, "Calculated average position for neighbourhood and used this to autocomplete location on very few entries.");

-- instant_bookable NULL handling
UPDATE airbnb_cleaned_data a
SET a.instant_bookable = 'FALSE'
WHERE a.instant_bookable IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "instant_bookable NULL handling", 105, "Used FALSE as the default option, since hosts might not be instantly available with their accommodation.");

-- cancellation_policy NULL handling
UPDATE airbnb_cleaned_data a
SET a.cancellation_policy = 'moderate'
WHERE a.cancellation_policy IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "cancellation_policy NULL handling", 76, "Used moderate as the default option.");

-- minimum_nights NULL handling
UPDATE airbnb_cleaned_data a
SET a.minimum_nights = '1'
WHERE a.minimum_nights IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "minimum_nights NULL handling", 400, "Used 1 as the default option.");

-- minimum_nights negative value handling
UPDATE airbnb_cleaned_data a
SET a.minimum_nights = '1'
WHERE a.minimum_nights<0 AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "minimum_nights negative value handling", 13, "Normalized values smaller than 0 to 1.");

-- availability_365 NULL and negative value handling
UPDATE airbnb_cleaned_data a
SET a.availability_365 = '0'
WHERE a.availability_365<0 AND a.id>0
	OR a.availability_365 IS NULL AND a.id>0;
    
-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "availability_365 NULL and negative value handling", 879, "Normalized all faulty values to 0.");

-- calculate row numbers and total for neighbourhood and construction year, so that we can calculate median
CREATE TEMPORARY TABLE neighborhood_construction_years AS
SELECT 
    neighbourhood,
    construction_year,
    ROW_NUMBER() OVER (
        PARTITION BY neighbourhood 
        ORDER BY construction_year
    ) AS row_num,
    COUNT(*) OVER (PARTITION BY neighbourhood) AS total
FROM airbnb_cleaned_data
WHERE construction_year IS NOT NULL;

-- calculate median, and use it to update missing construction year data
UPDATE airbnb_cleaned_data a
JOIN (
    SELECT 
        neighbourhood,
        AVG(construction_year) AS median_year
    FROM neighborhood_construction_years
    WHERE row_num BETWEEN total/2 AND total/2 + 1
    GROUP BY neighbourhood
) b ON a.neighbourhood = b.neighbourhood
SET a.construction_year = ROUND(b.median_year)
WHERE a.construction_year IS NULL AND a.id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "construction_year NULL handling", 213, "Used median to calculate which construction year is most applicable per neighbourhood.");

-- house_rules NULL handling
UPDATE airbnb_cleaned_data
SET house_rules = 'Standard rules apply'
WHERE house_rules IS NULL AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "house_rules NULL handling", 51841, "Set NULL values to 'Standard rules apply'");

-- house_rules #NAME? handling
UPDATE airbnb_cleaned_data
SET house_rules = 'Standard rules apply'
WHERE house_rules='#NAME?' AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "house_rules #NAME? handling", 2696, "Set faulty values to 'Standard rules apply'.");

-- reformat currency columns to numeric columns
ALTER TABLE airbnb_cleaned_data
RENAME COLUMN price TO price_$,
RENAME COLUMN service_fee TO service_fee_$;

-- price_$, service_fee$, currency handling, remove '$'
UPDATE airbnb_cleaned_data
SET 
    price_$ = REPLACE(price_$, '$', ''),
    service_fee_$ = REPLACE(service_fee_$, '$', '')
    WHERE id>0;

-- log changes    
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "price_$, service_fee$, currency handling", 102019, "Removed $ to standardize numbers, preparing to change format.");

-- price_$, service_fee$, currency handling, remove ','
UPDATE airbnb_cleaned_data
SET 
    price_$ = REPLACE(price_$, ',', ''),
    service_fee_$ = REPLACE(service_fee_$, ',', '')
    WHERE id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "price_$, service_fee$, currency handling", 17811, "Removed , to standardize numbers, preparing to change format.");

-- price_$, service_fee$, currency handling, reformat columns
ALTER TABLE airbnb_cleaned_data
MODIFY price_$ INT,
MODIFY service_fee_$ INT;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "price_$, service_fee$, currency handling", 102053, "Formatted colummns to INT to prepare for calculations. Every row affected.");

-- price_$ NULL handling, calculation
UPDATE airbnb_cleaned_data
SET price_$ = ROUND(5*service_fee_$,0)
WHERE price_$ IS NULL AND service_fee_$ IS NOT NULL AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "price_$ NULL handling", 213, "Used average multiplier of 5 to calculate missing price values.");

-- service_fee_$ NULL handling, calculation
UPDATE airbnb_cleaned_data
SET service_fee_$ = ROUND(0.2*price_$,0)
WHERE service_fee_$ IS NULL AND price_$ IS NOT NULL AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "service_fee_$ NULL handling", 239, "Used average multiplier of 0.2 to calculate missing price values.");

-- number_of_reviews NULL handling
UPDATE airbnb_cleaned_data
SET number_of_reviews = '0'
WHERE number_of_reviews IS NULL AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "number_of_reviews NULL handling", 183, "Set non-existent entries to 0.");

-- reviews_per_month NULL handling
UPDATE airbnb_cleaned_data
SET reviews_per_month = '0'
WHERE reviews_per_month IS NULL AND number_of_reviews='0' AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-23', "reviews_per_month NULL handling", 15795, "Set to 0 if entry does not exist and 0 reviews exist.");

-- availability_365 data correction
UPDATE airbnb_cleaned_data
SET availability_365 = 365
WHERE availability_365 > 365 AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-27', "availability_365 value correction", 2754, "Exceeding values corrected to 365 for max. available days during the year.");

-- index creation for efficiency of join to remove duplicates
CREATE INDEX idx_airbnb_name ON airbnb_cleaned_data(airbnb_name);
CREATE INDEX idx_host_name ON airbnb_cleaned_data(host_name);
CREATE INDEX idx_geo_lat ON airbnb_cleaned_data(geo_lat);
CREATE INDEX idx_geo_long ON airbnb_cleaned_data(geo_long);
CREATE INDEX idx_price_$ ON airbnb_cleaned_data(price_$);

-- delete duplicates depending on the values, round geo_lat and geo_long (4th decimal place is approx 11m accuracy)
DELETE FROM airbnb_cleaned_data
WHERE id IN (
    SELECT id FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    COALESCE(airbnb_name), 
                    COALESCE(host_name),
                    ROUND(geo_lat, 4),
                    ROUND(geo_long, 4),
                    price_$
                ORDER BY id
            ) AS dup_rank
        FROM airbnb_cleaned_data
    ) ranked
    WHERE dup_rank > 1
);

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-27', "Duplicate Listing Handling", 32667, "Removed bot accounts/multiple listings from users. Filtered by airbnb_name, host_name, geo_lat, geo_long and price_$");

-- re-calculate host_listings due to deletions
WITH host_listing_counts AS (
    SELECT 
        hostid, 
        COUNT(*) AS actual_listings
    FROM airbnb_cleaned_data
    GROUP BY hostid
)

UPDATE airbnb_cleaned_data a
JOIN host_listing_counts h 
    ON a.hostid = h.hostid
SET a.calculated_host_listings_count = h.actual_listings
WHERE id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-27', "host_listings_count correction", 27618, "Re-calculated the host_listings_count due to deletion of duplicates, fake listings or invalid data");


-- find out how to re-format dates, here: https://www.w3schools.com/sql/func_mysql_date_format.asp

-- temporary table to not make mistakes
CREATE TABLE date_format_correction AS (
SELECT 
    id, last_review FROM airbnb_cleaned_data
WHERE last_review IS NOT NULL);
ALTER TABLE date_format_correction
ADD corrected_date DATE;
-- Disable safe mode
SET SQL_SAFE_UPDATES = 0;
-- Run update
UPDATE date_format_correction
SET corrected_date = 
    CASE
        WHEN last_review REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN 
            STR_TO_DATE(last_review, '%c/%e/%Y')
        ELSE NULL
    END;
-- Re-enable safe mode
SET SQL_SAFE_UPDATES = 1;

-- insert new dates into original table
UPDATE airbnb_cleaned_data a JOIN date_format_correction d 
    SET a.last_review = d.corrected_date
    WHERE d.id = a.id;
    
-- drop unnecessary table
DROP TABLE date_format_correction;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-27', "last_review date re-format", 58546, "Changed the m/d/YYYY format to YYYY-MM-DD for SQL column formatting.");

-- UPDATE ALL TABLE COLUMN TYPES
ALTER TABLE airbnb_cleaned_data
MODIFY host_identity_verified VARCHAR(20);

ALTER TABLE airbnb_cleaned_data
MODIFY neighbourhood_group VARCHAR(50);

ALTER TABLE airbnb_cleaned_data
MODIFY neighbourhood VARCHAR(50);

ALTER TABLE airbnb_cleaned_data
MODIFY geo_lat FLOAT(10,6);

ALTER TABLE airbnb_cleaned_data
MODIFY geo_long FLOAT(10,6);

ALTER TABLE airbnb_cleaned_data
MODIFY country VARCHAR(50);

ALTER TABLE airbnb_cleaned_data
MODIFY country_code VARCHAR(3);

ALTER TABLE airbnb_cleaned_data
MODIFY instant_bookable VARCHAR(5);

ALTER TABLE airbnb_cleaned_data
MODIFY cancellation_policy VARCHAR(20);

ALTER TABLE airbnb_cleaned_data
MODIFY room_type VARCHAR(30);

ALTER TABLE airbnb_cleaned_data
MODIFY construction_year INT(4);

ALTER TABLE airbnb_cleaned_data
MODIFY minimum_nights INT(5);

ALTER TABLE airbnb_cleaned_data
MODIFY number_of_reviews INT(6);

ALTER TABLE airbnb_cleaned_data
MODIFY last_review DATE;

ALTER TABLE airbnb_cleaned_data
MODIFY reviews_per_month FLOAT(10,2);

ALTER TABLE airbnb_cleaned_data
MODIFY review_rate_number INT(1);

ALTER TABLE airbnb_cleaned_data
MODIFY calculated_host_listings_count INT(3);

ALTER TABLE airbnb_cleaned_data
MODIFY availability_365 INT(3);

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "Datatype modification", 69386, "Updated the data types in every column to more accurately represent the data inside.");

-- create new table to be able to do transformations, while keeping cleaned version of original file
CREATE TABLE airbnb_cleaned_data_transformable LIKE airbnb_cleaned_data;
    
INSERT INTO airbnb_cleaned_data_transformable
SELECT * FROM airbnb_cleaned_data;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "NEW TABLE", 69386, "Copied table over to 'airbnb_cleaned_data_transformable', which needs a few cleaning steps before we do transformations.");

-- Delete the rows without price/service fee, since these are not usable for transformation
DELETE
FROM airbnb_cleaned_data_transformable
WHERE (price_$ IS NULL OR service_fee_$ IS NULL) AND id>0;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "NEW TABLE - removed NULL costs", 34, "Deleted every row that contained NULL price or service fee, since these are not usable for transformation.");

-- drop license column
ALTER TABLE airbnb_cleaned_data_transformable
DROP COLUMN license;

-- log changes
INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "NEW TABLE - dropped column", 0, "Removed license column, since this has no use for transformation.");