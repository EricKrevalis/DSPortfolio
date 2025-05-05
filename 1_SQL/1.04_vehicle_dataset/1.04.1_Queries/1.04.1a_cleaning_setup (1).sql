-- create first base table setup, define all columns as nullable initially (or able to have empty strings)
-- CREATE TABLE stagingtable (
--    id INT AUTO_INCREMENT PRIMARY KEY,
--    column1 VARCHAR(255),
--    column2 VARCHAR(255),
--    );
    
-- Importing data with INFILE instead of import wizard. Since data is NOT clean and very large
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/0.XX_DFNAME/0.XX.1_Raw/DATASET.csv'
-- INTO TABLE stagingtable
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- -- IGNORE 1 ROWS -- only need this if 1st row is empty
-- (id, column1, column2
-- );

-- make second table which we will use to clean
-- CREATE TABLE cleanedtable (
--    id INT AUTO_INCREMENT PRIMARY KEY,
--    column1 VARCHAR(255),
--    column2 VARCHAR(255),
--    );
-- Define all columns as nullable initially? maybe helps cleaning
    
-- insert our imported table into our cleaning table
-- INSERT INTO cleanedtable
-- SELECT * FROM stagingtable;

-- create log table, to properly track which changes have been made
-- CREATE TABLE DFNAME_cleaning_log (
-- id INT AUTO_INCREMENT PRIMARY KEY,
-- cleaning_date DATE,
-- operation VARCHAR(255),
-- affected_rows INT,
-- notes TEXT
-- );