-- Create raw staging table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_deliveries_raw_data_staging (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id VARCHAR(255),
    inning VARCHAR(255),
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255),
    `over` VARCHAR(255),
    ball VARCHAR(255),
    batter VARCHAR(255),
    bowler VARCHAR(255),
    non_striker VARCHAR(255),
    batsman_runs VARCHAR(255),
    extra_runs VARCHAR(255),
    total_runs VARCHAR(255),
    extras_type VARCHAR(255),
    is_wicket VARCHAR(255),
    player_dismissed VARCHAR(255),
    dismissal_kind VARCHAR(255),
    fielder VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/05_ipl_complete_dataset_(2008-2024)/0_Raw/deliveries.csv'
INTO TABLE 05_ipl_complete_dataset_2008_2024.ipl_deliveries_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(match_id, inning, batting_team, bowling_team, `over` , ball, batter, bowler, non_striker, batsman_runs, extra_runs, total_runs, extras_type, is_wicket, player_dismissed, dismissal_kind, fielder);

-- Create cleaning table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_deliveries_cleaned_data LIKE 05_ipl_complete_dataset_2008_2024.ipl_deliveries_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 05_ipl_complete_dataset_2008_2024.ipl_deliveries_cleaned_data
SELECT * FROM 05_ipl_complete_dataset_2008_2024.ipl_deliveries_raw_data_staging;

-- Create log table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_deliveries_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 05_ipl_complete_dataset_2008_2024.ipl_deliveries_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 260920, 'Created staging, cleaning and logging tables.');


-- Create raw staging table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_matches_raw_data_staging (
    auto_id INT AUTO_INCREMENT PRIMARY KEY,
    id VARCHAR(255),
    season VARCHAR(255),
    city VARCHAR(255),
    date VARCHAR(255),
    match_type VARCHAR(255),
    player_of_match VARCHAR(255),
    venue VARCHAR(255),
    team1 VARCHAR(255),
    team2 VARCHAR(255),
    toss_winner VARCHAR(255),
    toss_decision VARCHAR(255),
    winner VARCHAR(255),
    result VARCHAR(255),
    result_margin VARCHAR(255),
    target_runs VARCHAR(255),
    target_overs VARCHAR(255),
    super_over VARCHAR(255),
    method VARCHAR(255),
    umpire1 VARCHAR(255),
    umpire2 VARCHAR(255)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/05_ipl_complete_dataset_(2008-2024)/0_Raw/matches.csv'
INTO TABLE 05_ipl_complete_dataset_2008_2024.ipl_matches_raw_data_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, season, city, date, match_type, player_of_match, venue, team1, team2, toss_winner, toss_decision, winner, result, result_margin, target_runs, target_overs, super_over, method, umpire1, umpire2);

-- Create cleaning table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_matches_cleaned_data LIKE 05_ipl_complete_dataset_2008_2024.ipl_matches_raw_data_staging;

-- Copy data to cleaning table
INSERT INTO 05_ipl_complete_dataset_2008_2024.ipl_matches_cleaned_data
SELECT * FROM 05_ipl_complete_dataset_2008_2024.ipl_matches_raw_data_staging;

-- Create log table
CREATE TABLE 05_ipl_complete_dataset_2008_2024.ipl_matches_cleaning_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cleaning_date DATE,
    operation VARCHAR(255),
    affected_rows INT,
    notes TEXT
);

-- Log initial setup
INSERT INTO 05_ipl_complete_dataset_2008_2024.ipl_matches_cleaning_log (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-07-29', 'Table creation', 1095, 'Created staging, cleaning and logging tables.');