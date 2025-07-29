-- Create raw staging table
CREATE TABLE 09_google_play_store_apps.google_playstore_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    App_Name VARCHAR(255),
    App_Id VARCHAR(255),
    Category VARCHAR(255),
    Rating VARCHAR(255),
    Rating_Count VARCHAR(255),
    Installs VARCHAR(255),
    Minimum_Installs VARCHAR(255),
    Maximum_Installs VARCHAR(255),
    Free VARCHAR(255),
    Price VARCHAR(255),
    Currency VARCHAR(255),
    Size VARCHAR(255),
    Minimum_Android VARCHAR(255),
    Developer_Id VARCHAR(255),
    Developer_Website VARCHAR(255),
    Developer_Email VARCHAR(255),
    Released VARCHAR(255),
    Last_Updated VARCHAR(255),
    Content_Rating VARCHAR(255),
    Privacy_Policy TEXT,
    Ad_Supported VARCHAR(255),
    In_App_Purchases VARCHAR(255),
    Editors_Choice VARCHAR(255),
    Scraped_Time VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/09_google_play_store_apps/0_Raw/Google-Playstore.csv'
INTO TABLE 09_google_play_store_apps.google_playstore_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(App_Name, App_Id, Category, Rating, Rating_Count, Installs, Minimum_Installs, Maximum_Installs, Free, Price, Currency, Size, Minimum_Android, Developer_Id, Developer_Website, Developer_Email, Released, Last_Updated, Content_Rating, Privacy_Policy, Ad_Supported, In_App_Purchases, Editors_Choice, Scraped_Time);

-- Create cleaning table
CREATE TABLE 09_google_play_store_apps.google_playstore_cleaned_data LIKE 09_google_play_store_apps.google_playstore_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 09_google_play_store_apps.google_playstore_cleaned_data
SELECT * FROM 09_google_play_store_apps.google_playstore_raw_data_staging;

-- Create log table
CREATE TABLE 09_google_play_store_apps.google_playstore_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 09_google_play_store_apps.google_playstore_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 2312944, 'Created staging, cleaning and logging tables.');