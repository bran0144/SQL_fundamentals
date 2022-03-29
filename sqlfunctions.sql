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

-- EXTRACT(), DATEPART(), DATE_TRUNC()
-- lets you extract and manipulate timestamps
SELECT EXTRACT(quarter FROM timestamp '2005-01-24 05:12:00') as quarter;

SELECT DATE_PART('quarter', timestamp '2005-01-24 05:12:00') as quarter;

-- extracing subfields from timestamp data
SELECT
    EXTRACT(quarter FROM payment_date) AS quarter,
    EXTRACT(year FROM payment_date) AS year,
    SUM(amount) AS total_payments
FROM payment_date
GROUP BY 1, 2;

SELECT DATE_TRUNC('year', TIMESTAMP '2005-01-24 05:12:00');

-- Exercises
SELECT 
  -- Extract day of week from rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek 
FROM rental 
LIMIT 100;

-- Extract day of week from rental_date
SELECT 
  EXTRACT(dow FROM rental_date) AS dayofweek, 
  -- Count the number of rentals
  COUNT(rental_id) as rentals 
FROM rental 
GROUP BY 1;

-- Truncate rental_date by year
SELECT DATE_TRUNC('year', rental_date) AS rental_year
FROM rental;

-- Truncate rental_date by month
SELECT DATE_TRUNC('month', rental_date) AS rental_month
FROM rental;

-- Truncate rental_date by day of the month 
SELECT DATE_TRUNC('day', rental_date) AS rental_day 
FROM rental;

SELECT 
  DATE_TRUNC('day', rental_date) AS rental_day,
  -- Count total number of rentals 
  COUNT(rental_id) AS rentals 
FROM rental
GROUP BY 1;

SELECT 
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek,
  AGE(return_date, rental_date) AS rental_days
FROM rental AS r 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  rental_date BETWEEN CAST('2005-05-01' AS DATE)
   AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';

SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  r.rental_date BETWEEN CAST('2005-05-01' AS DATE) 
  AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';

-- Reformatting string and char data
-- String concatenation
SELECT
    first_name,
    last_name,
    first_name || ' ' || last_name AS full_name
FROM customer;

-- OR you can use the CONCAT function
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
FROM customer;
-- Can concatenate non-string data too (with eiterh || or CONCAT)
SELECT
    customer_id || ': ' || first_name || ' ' || last_name AS full_name
FROM customer;

-- reformatting for upper or lower case, UPPER, LOWER, INITCAP
SELECT
    UPPER(email)
FROM customer;

SELECT
    LOWER(title)
FROM film;

SELECT
    INITCAP(title)
FROM film;

-- replacing char in a string
SELECT
    REPLACE(description, 'A Astounding',
        'An Astounding') as description
FROM film;
-- Using reverse
SELECT  
    title,
    REVERSE(title)
FROM film AS f;

-- Exercises:

-- Concatenate the first_name and last_name and email 
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email 
FROM customer;

-- Concatenate the first_name and last_name and email
SELECT CONCAT(first_name, ' ', last_name,  ' <', email, '>') AS full_email 
FROM customer;

SELECT 
  -- Concatenate the category name to coverted to uppercase
  -- to the film title converted to title case
  UPPER(c.name)  || ': ' || INITCAP(f.title) AS film_category, 
  -- Convert the description column to lowercase
  LOWER(description) AS description
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;

SELECT 
  -- Replace whitespace in the film title with an underscore
  REPLACE(title, ' ', '_') AS title
FROM film; 

-- Parsing string and char data
-- CHAR_LENGTH() - returns the length of a string (int)
SELECT
    title,
    CHAR_LENGTH(title)
FROM film;
-- LENGTH() - works the same as CHAR_LENGTH()
-- POSITION - returns the position (as an int) of char
SELECT
    email,
    POSITION('@' IN email)
FROM customer;
-- STRPOS - similar to POSITION, but different syntax
SELECT
    email,
    STRPOS(email, '@')
FROM customer;
-- Parsing
-- LEFT - returns first n char from string
SELECT
    LEFT(description, 50)
FROM film;
-- similar to LEFT, just goes the other way
SELECT
    RIGHT(description, 50)
FROM film;
-- SUBSTRING(source_string/col, StartPOS(int), EndPOS(int))
SELECT
    SUBSTRING(description, 10, 50)
FROM film AS f;
-- Can be used together, say to get the left side of an email
SELECT
    SUBSTRING(email FROM 0 FOR POSITION('@' IN email))
FROM
    customer;
-- to get the right characters from an email
SELECT
    SUBSTRING(email FROM POSITION('@' IN email) +1 FOR CHAR_LENGTH(email))
FROM
    customer;

-- Exercises:
SELECT 
  -- Select the title and description columns
  title,
  description,
  -- Determine the length of the description column
  CHAR_LENGTH(description) AS desc_len
FROM film;

SELECT 
  -- Select the first 50 characters of description
  LEFT(description, 50) AS short_desc
FROM 
  film AS f; 

SELECT 
  -- Select only the street name from the address table
  SUBSTRING(address FROM POSITION(' ' IN address)+1 FOR CHAR_LENGTH(address))
FROM 
  address;

SELECT
  -- Extract the characters to the left of the '@'
  LEFT(email, POSITION('@' IN email)-1) AS username,
  -- Extract the characters to the right of the '@'
  SUBSTRING(email FROM POSITION('@' IN email) +1 FOR CHAR_LENGTH(email)) AS domain
FROM customer;

