-- Window functions
-- perform an operation across a set of rows that relate to the current row
-- similar to group by aggregations, but all rows remain in the output
-- used for: 
-- - fetching values outside of current row
-- - determine reigning chamption
-- - calculate growth over time
-- - ranks, running totals, running averages
-- - can add row numbers

SELECT 
year, event, country
ROW_NUMBER() OVER() AS Row_N
FROM Summer_medals
WHERE Medal = 'Gold';

-- Exercises:

SELECT
Year,

-- Assign numbers to each year
ROW_NUMBER() OVER () AS Row_N
FROM (
SELECT DISTINCT Year
FROM Summer_Medals
ORDER BY Year ASC
) AS Years
ORDER BY Year ASC;

-- ORDER BY
-- Using descending
SELECT 
year, event, country
ROW_NUMBER() OVER(ORDER BY Year DESC) AS Row_N
FROM Summer_medals
WHERE Medal = 'Gold';

-- Can order by multiple columns

SELECT 
year, event, country
ROW_NUMBER() OVER(ORDER BY Year DESC, Event ASC) AS Row_N
FROM Summer_medals
WHERE Medal = 'Gold';

-- Can order inside or outside the OVER at the same time

SELECT 
year, event, country
ROW_NUMBER() OVER(ORDER BY Year DESC, Event ASC) AS Row_N
FROM Summer_medals
WHERE Medal = 'Gold'
ORDER BY Country ASC, Row_N ASC;

-- Reigning champion
-- LAG - returns a column's value at the row n rows before the current value

SELECT 
Year, Country AS Champion
FROM Summer_Medals
WHERE Year IN (1996, 2000, 2004, 2008, 2012)
AND Gender = 'Men' and Medal = 'Gold'
AND Event = 'Discus throw';

WITH Discus_Gold AS (
SELECT 
Year, Country AS Champion
FROM Summer_Medals
WHERE Year IN (1996, 2000, 2004, 2008, 2012)
AND Gender = 'Men' and Medal = 'Gold'
AND Event = 'Discus throw')
SELECT
Year, Champion,
LAG(Champion, 1) OVER
(ORDER BY Year ASC) AS Last_Champion
FROM Discus_Gold
ORDER BY Year ASC;

-- Exercises:

SELECT
Year,
-- Assign the lowest numbers to the most recent years
ROW_NUMBER() OVER(ORDER BY Year DESC) AS Row_N
FROM (
SELECT DISTINCT Year
FROM Summer_Medals
) AS Years
ORDER BY Year;

SELECT
-- Count the number of medals each athlete has earned
athlete,
COUNT(medal) AS Medals
FROM Summer_Medals
GROUP BY Athlete
ORDER BY Medals DESC;

WITH Athlete_Medals AS (
SELECT
-- Count the number of medals each athlete has earned
Athlete,
COUNT(*) AS Medals
FROM Summer_Medals
GROUP BY Athlete)

SELECT
-- Number each athlete by how many medals they've earned
Athlete,
ROW_NUMBER() OVER (ORDER BY Medals DESC) AS Row_N
FROM Athlete_Medals
ORDER BY Medals DESC;

SELECT
-- Return each year's champions' countries
Year,
country AS champion
FROM Summer_Medals
WHERE
Discipline = 'Weightlifting' AND
Event = '69KG' AND
Gender = 'Men' AND
Medal = 'Gold';

WITH Weightlifting_Gold AS (
SELECT
-- Return each year's champions' countries
Year,
Country AS champion
FROM Summer_Medals
WHERE
Discipline = 'Weightlifting' AND
Event = '69KG' AND
Gender = 'Men' AND
Medal = 'Gold')

SELECT
Year, Champion,
-- Fetch the previous year's champion
LAG(Champion) OVER
(ORDER BY Year ASC) AS Last_Champion
FROM Weightlifting_Gold
ORDER BY Year ASC;