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

-- Timestamps
-- ISO 8601 format (Postgres) yyyy-mm-dd
-- without time zone is the default behavior
-- INTERVAL
SELECT rental_date + INTERVAL '3 days' as expected_return
FROM rental;

-- Exercise
SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + INTERVAL '3 days' AS expected_return_date
FROM rental;

-- Arrays
-- creating tables
CREATE TABLE grades (
    student_id int,
    email text [][],
    test_scores int[]
);
INSERT INTO grades
    VALUES (1, '{{"work", "work1@datacamp.com"},{"other", "other1@datacamp.com"}}',
    '{92, 85, 96, 88}'
    );

-- Accessing arrays
-- indexes at 1 NOT zero
SELECT 
    email[1][1] AS type,
    email[1][2] AS address,
    test_scores[1],
FROM grades
-- can also index in the WHERE clause as a filter
WHERE 'other' = ANY (email);

-- using contains operator - works similar to ANY
WHERE email @> ARRAY['other'];

-- Exercises:
-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers';

-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);

SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];

-- arithmetic operators
-- adding and subtracting date/time data
-- return type may vary
-- when you subtract date types, you get an integer back
SELECT date '2005-09-11' - date '2005-09-10';   --returns 1
-- when you add, you get a date back
SELECT date '2005-09-11' + integer '3';  -- returns 2005-09-14
-- subtracting two dates returns an interval
SELECT date '2005-09-11' - date '2005-09-09 12:00:00';  --returns 1 day 12:00:00
--calculates time periods with AGE 
SELECT AGE(timestamp '2005-09-11 00:00:00', timestamp '2005-09-09 12:00:00') -- returns an interval
-- Using INTERVAL
SELECT timestamp '2019-05-01' + 21 * INTERVAL '1 day';

-- Exercises:
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
    r.return_date - r.rental_date AS days_rented
FROM film AS f
     INNER JOIN inventory AS i ON f.film_id = i.film_id
     INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
	AGE(r.return_date, r.rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    INTERVAL '1' day * f.rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date IS NOT NULL
ORDER BY f.title;

SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- current timestamp
SELECT NOW();
-- :: casts type and is specific to postgres
SELECT NOW()::timestamp;
-- CAST() function to change tyoe
SELECT CAST(NOW() as timestamp);
-- can also use
SELECT CURRENT_TIMESTAMP;
-- also has a precision parameter
SELECT CURRENT_TIMESTAMP(2);
-- date and time are also available as current
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;

-- Exercises:
--Select the current timestamp without timezone
SELECT CURRENT_TIMESTAMP::timestamp AS right_now;

SELECT
	CURRENT_TIMESTAMP::timestamp AS right_now,
    INTERVAL '5 days' + CURRENT_TIMESTAMP AS five_days_from_now;

-- seconds level precision
SELECT
	CURRENT_TIMESTAMP(2)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(2) AS five_days_from_now;

