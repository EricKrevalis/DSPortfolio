-- create table to transform data in
CREATE TABLE airbnb_transformed_data_v1 LIKE airbnb_cleaned_data_transformable;
INSERT INTO airbnb_transformed_data_v1 SELECT * FROM airbnb_cleaned_data_transformable;
-- create transformation log file
CREATE TABLE airbnb_transformation_log_v1 LIKE airbnb_cleaning_log;

INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "airbnb_transformed_data_v1 creation", 69352, "Created new table to do transformation operations on.");

/* -- TODO
-- Export current files (raw, cleaned, transformable) into resulting files for project
-- Start transformation :)
*/