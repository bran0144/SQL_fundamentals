-- Data types - 
-- Text - CHAR, VARCHAR
-- Numeric - INT, DECIMAL
-- data types are stored in information schema
SELECT
    column_name,
    data_type 
FROM INFORMATION_SCHEMA.columns
WHERE column_name in ('title', 'description', 'special_features')
    AND table_name = 'film';

-- Exercises:

 -- Select all columns from the TABLES system database
 SELECT * 
 FROM INFORMATION_SCHEMA.TABLES
 -- Filter by schema
 WHERE table_schema = 'public';

  -- Select all columns from the COLUMNS system database
 SELECT * 
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE table_name = 'actor';

 -- Get the column name and data type
SELECT
 	column_name, 
    data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';

