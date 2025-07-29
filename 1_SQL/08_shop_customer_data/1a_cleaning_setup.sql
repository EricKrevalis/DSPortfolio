-- Create raw staging table
CREATE TABLE 08_shop_customer_data.shopcustomer_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(255),
    Gender VARCHAR(255),
    Age VARCHAR(255),
    Annual_Income_USD VARCHAR(255),
    Spending_Score_1_100 VARCHAR(255),
    Profession VARCHAR(255),
    Work_Experience VARCHAR(255),
    Family_Size VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/08_shop_customer_data/0_Raw/Customers.csv'
INTO TABLE 08_shop_customer_data.shopcustomer_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, Gender, Age, Annual_Income_USD, Spending_Score_1_100, Profession, Work_Experience, Family_Size);

-- Create cleaning table
CREATE TABLE 08_shop_customer_data.shopcustomer_cleaned_data LIKE 08_shop_customer_data.shopcustomer_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 08_shop_customer_data.shopcustomer_cleaned_data
SELECT * FROM 08_shop_customer_data.shopcustomer_raw_data_staging;

-- Create log table
CREATE TABLE 08_shop_customer_data.shopcustomer_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 08_shop_customer_data.shopcustomer_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 2000, 'Created staging, cleaning and logging tables.');