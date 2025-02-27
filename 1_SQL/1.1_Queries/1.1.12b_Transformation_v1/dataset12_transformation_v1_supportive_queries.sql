-- often used to check/veryify tables, take a peek at what might need to be done
-- check original table
select * from airbnb_cleaned_data_transformable;

-- v1
-- check transformed data table
select * from airbnb_transformed_data_v1;
-- check log table
select * from airbnb_transformation_log_v1;