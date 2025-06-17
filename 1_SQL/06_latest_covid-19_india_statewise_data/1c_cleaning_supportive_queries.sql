-- often used to check/veryify tables, take a peek at what might need to be done
-- original data
-- select * from stagingtable;
-- check cleaned data table
-- select * from cleanedtable;
-- new table
-- select * from transformabletable;
-- check log table
-- select * from logtable;

-- base log file syntax:
-- log changes
-- INSERT INTO table2 (cleaning_date, operation, affected_rows, notes)
-- 	VALUES ('YYYY-MM-DD', "OPERATION", 0, "NOTES");

-- data types
select * from information_schema.columns;

-- export csv
-- INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airbnb_cleaned_data.csv' -- Adjust name/location
-- NEEDED SOME EXTRA CLEANING IN TEXT
-- Clean other text fields if needed (neighbourhood, host_name, etc.)

-- Checked local permissions to identify file location
SHOW VARIABLES LIKE 'secure_file_priv';

-- finding locks in MySQL 8.0+
SELECT * FROM performance_schema.metadata_locks 
WHERE OBJECT_SCHEMA = 'SCHEMANAME'; -- adjust schema name here

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
WHERE mdl.OBJECT_SCHEMA = 'SCHEMANAME'; -- Adjust schema name here

-- kill blocked connections
-- KILL 14;
-- KILL 15;
-- KILL 16;
-- KILL 9;

-- check for duplicates, by grouping
-- can use hash function to figure out how duplicates exist
-- RESULT: hash function works terribly. partition/coalesce is better at filtering for unique entries, take a peek at them
-- distinct still has issues, since i was only displaying the unique