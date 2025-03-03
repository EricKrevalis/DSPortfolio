-- often used to check/veryify tables, take a peek at what might need to be done
-- check original table
select * from airbnb_cleaned_data_transformable;

-- v2
-- check transformed data table/s
-- #1
select * from airbnb_transformation_v2_policy_price;
-- #2
select * from airbnb_transformation_v2_policy_bookable_price;
-- #3
select * from airbnb_transformation_v2_policy_rules;
-- #4
select * from airbnb_transformation_v2_policy_location;

-- check log table
select * from airbnb_transformation_log_v2;