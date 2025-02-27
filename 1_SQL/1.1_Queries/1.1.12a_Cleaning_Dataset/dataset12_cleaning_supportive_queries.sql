-- often used to check/veryify tables, take a peek at what might need to be done
-- check cleaned data table
select * from airbnb_cleaned_data;
-- new table
select * from airbnb_cleaned_data_transformable;
-- check log table
select * from airbnb_cleaning_log;
-- data types
select * from information_schema.columns;

-- base log file syntax:
-- log changes
-- INSERT INTO airbnb_cleaning_log (cleaning_date, operation, affected_rows, notes)
-- VALUES ('2025-02-22', "CHANGES MADE", 999, "NOTES. e.g. issues, steps to create solution, assumptions made");

-- Checked local permissions to identify file location
SHOW VARIABLES LIKE 'secure_file_priv';

-- Function: Grab all column names without ID; Since we use primary key and therefor there's a column mismatch
SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'airbnb_raw_data_staging'
  AND TABLE_SCHEMA = 'airbnb_cleaning_sql'
  AND COLUMN_NAME != 'id';

-- peeking at id duplicates, making sure they occur the way i suspect
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

-- This kept timing out, even after changing limited time to 300s, try to find problem
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
-- KILL 14;
-- KILL 15;
-- KILL 16;
-- KILL 9;

-- checked for duplicates in neighbourhood-neighbourhood_group association
CREATE TEMPORARY TABLE neighbourhood_lookup_a AS
SELECT 
    neighbourhood,
    neighbourhood_group,
    COUNT(*) AS count
FROM airbnb_cleaned_data
WHERE neighbourhood_group IS NOT NULL
GROUP BY neighbourhood, neighbourhood_group
ORDER BY neighbourhood, count DESC;
CREATE TEMPORARY TABLE neighbourhood_lookup_b AS
SELECT 
    neighbourhood,
    neighbourhood_group,
    COUNT(*) AS count
FROM airbnb_cleaned_data
WHERE neighbourhood_group IS NOT NULL
GROUP BY neighbourhood, neighbourhood_group
ORDER BY neighbourhood, count DESC;
SELECT *
	FROM neighbourhood_lookup_a
    INNER JOIN neighbourhood_lookup_b
	ON neighbourhood_lookup_a.neighbourhood=neighbourhood_lookup_b.neighbourhood
    AND neighbourhood_lookup_a.neighbourhood_group!=neighbourhood_lookup_b.neighbourhood_group;
    
-- created hash function to figure out how duplicates exist
WITH listing_fingerprints AS (
    SELECT 
        *,
        MD5(CONCAT(
            airbnb_name, 
            host_name
        )) AS listing_hash
    FROM airbnb_cleaned_data
),
duplicate_listings AS (
    SELECT 
		id,
        listing_hash,
        hostid,
        ROW_NUMBER() OVER (
            PARTITION BY listing_hash 
            ORDER BY listing_hash
        ) AS dup_rank
    FROM listing_fingerprints WHERE listing_hash IS NOT NULL
)
SELECT * FROM airbnb_cleaned_data WHERE id IN (SELECT id FROM duplicate_listings WHERE listing_hash IS NOT NULL AND dup_rank>1);

-- RESULT: hash function works terribly. partition/coalesce is better at filtering for unique entries, take a peek at them
        
-- distinct still has issues, since i was only displaying the unique
        
WITH duplicates_to_delete AS (
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
)
SELECT d.*, o.* 
FROM duplicates_to_delete d
JOIN airbnb_cleaned_data o ON d.id = o.id
WHERE d.dup_rank > 1;