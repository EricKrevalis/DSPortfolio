-- often used to check/veryify tables, take a peek at what might need to be done
-- check original table
select * from airbnb_cleaned_data_transformable;

-- v1
-- check transformed data table/s
-- #1
select * from airbnb_transformation_v1_host_price;
-- #2
select * from airbnb_transformation_v1_host_roomtype;
-- #3
select * from airbnb_transformation_v1_host_neighbourhood;
-- #4
select * from airbnb_transformation_v1_host_policy;

-- check log table
select * from airbnb_transformation_log_v1;