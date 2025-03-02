-- create table to transform data in
CREATE TABLE airbnb_transformed_data_v1 LIKE airbnb_cleaned_data_transformable;
INSERT INTO airbnb_transformed_data_v1 SELECT * FROM airbnb_cleaned_data_transformable;
-- create transformation log file
CREATE TABLE airbnb_transformation_log_v1 LIKE airbnb_cleaning_log;
-- log changes
INSERT INTO airbnb_transformation_log_v1 (cleaning_date, operation, affected_rows, notes)
VALUES ('2025-02-28', "airbnb_transformed_data_v1 creation", 69352, "Created new table to do transformation operations on.");

/* -- TODO
-- Start transformation :)
-- Make plans on how to transform
-- Transform in SQL, Java, R
-- Can also use Tableau and PowerBI for transformation into reports, since data is set up already
*/