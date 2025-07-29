-- create first base table setup, define all columns as nullable initially (or able to have empty strings)
CREATE TABLE 01_avocado_prices.avocado_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UnnamedCol VARCHAR(255),
    Date VARCHAR(255),
    AveragePrice VARCHAR(255),
    Total_Volume VARCHAR(255),
    type_4046 VARCHAR(255),
    type_4225 VARCHAR(255),
    type_4770 VARCHAR(255),
    Total_Bags VARCHAR(255),
    Small_Bags VARCHAR(255),
    Large_Bags VARCHAR(255),
    XLarge_Bags VARCHAR(255),
    type VARCHAR(255),
    year VARCHAR(255),
    region VARCHAR(255)
);
    
-- Importing data with INFILE instead of import wizard. Since data is NOT clean and very large
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/01_avocado_prices/0_Raw/avocado.csv'
INTO TABLE 01_avocado_prices.avocado_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(UnnamedCol, Date, AveragePrice, Total_Volume, type_4046, type_4225, type_4770, Total_Bags, Small_Bags, Large_Bags, XLarge_Bags, type, year, region);

-- make second table which we will use to clean
CREATE TABLE 01_avocado_prices.avocado_cleaned_data LIKE 01_avocado_prices.avocado_raw_data_staging;
    
-- insert our imported table into our cleaning table
INSERT INTO 01_avocado_prices.avocado_cleaned_data
SELECT * FROM 01_avocado_prices.avocado_raw_data_staging;

-- create log table, to properly track which changes have been made
CREATE TABLE 01_avocado_prices.avocado_cleaning_log (
id INT AUTO_INCREMENT PRIMARY KEY,
cleaning_date DATE,
operation VARCHAR(255),
affected_rows INT,
notes TEXT
);

-- log changes
INSERT INTO 01_avocado_prices.avocado_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-06-30', "Table creation", 18249, "Created staging, cleaning and logging tables.");