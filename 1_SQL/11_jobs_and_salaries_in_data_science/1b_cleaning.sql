-- Update: make NULL for missing data!
-- Update text columns for empty string ''
-- UPDATE table1
-- 	WHERE id > 0; -- Use the primary key to satisfy safe update mode

-- log changes
-- INSERT INTO table2 (cleaning_date, operation, affected_rows, notes)
-- VALUES ('YYYY-MM-DD', "OPERATION", 0, "NOTES");

-- try index creation, for long queries/joins
-- CREATE INDEX idx_column1 ON table1(column1);
-- CREATE INDEX idx_column2 ON table1(column2);

-- try deleting duplicates
-- DELETE t1
-- FROM table1 AS t1
-- INNER JOIN table1 AS t2
--    ON t1.columnid = t2.columnid
--    AND t1.id > t2.id	-- Keep older/lower ID
--    WHERE t1.id > 0;	-- ensure safe update mode is satisfied

-- log changes
-- INSERT INTO table2 (cleaning_date, operation, affected_rows, notes)
-- VALUES ('YYYY-MM-DD', "OPERATION", 0, "NOTES");