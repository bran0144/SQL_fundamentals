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

-- PARTITION BY 
-- Splits table into partitions based on a columns' unique values
-- Not rolled into one column (like GROUP BY)
-- operated sepearted by windoe function

WITH Discus_Gold AS (
SELECT
-- Return each year's champions' countries
    Year,
    Event,
    Country AS champion
FROM Summer_Medals
WHERE
    Year IN (2004, 2008, 2012)
    Event = ('Discus Throw', 'Triple Jump'_ AND
    Gender = 'Men' AND
    Medal = 'Gold')
SELECT 
    Year, Event, Champion,
    LAG(Champion) OVER
        (PARTITION BY Event
            ORDER BY Event ASC, Year ASC) AS Last_Champion
FROM Discus_Gold
ORDER BY EVENT ASC, YEAR ASC;

-- partitioned by year and country
WITH Country_gold AS (
    SELECT DISTINCT Year, Country, Event
    FROM Summer_Medals
    WHERE Year IN (2008, 2012)
    AND Country IN ('CHN', 'JPN')
    AND Gender = 'Women' AND Medal = 'Gold'
)
SELECT Year, Country, Event,
    ROW_NUMBER() OVER (PARTITION BY Year, Country)
FROM Country_gold;

-- Exercises

WITH Tennis_Gold AS (
  SELECT DISTINCT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Event = 'Javelin Throw' AND
    Medal = 'Gold')

SELECT
  Gender, Year,
  Country AS Champion,
  -- Fetch the previous year's champion by gender
  LAG(Country) OVER (PARTITION BY Gender
            ORDER BY Year ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender ASC, Year ASC;

WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold')

SELECT
  Gender, Year, Event,
  Country AS Champion,
  -- Fetch the previous year's champion by gender and event
  LAG(Country) OVER (PARTITION BY Gender, Event
            ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;

-- Fetching
LAG(column, n) --returns column's value at the row n rows before the current row
LEAD(column, n) -- returns column's value at hte row n rows after the current row

FIRST_VALUE(column) -- returns the first value in the table or partition
LAST_VALUE(column) -- returns the last value in the table or partition

WITH Hosts AS (
    SELECT DISTINCT Year, City
    FROM Summer_Medals
)
SELECT Year, City,
    LEAD(City, 1) OVER (ORDER BY Year ASC) AS Next_City,
    LEAD(City, 2) OVER (ORDER BY Year ASC) AS After_Next_City
FROM Hosts
ORDER BY Year ASC;

SELECT Year, City,
    FIRST_VALUE(City) OVER (ORDER BY Year ASC) AS First_city,
    LAST_VALUE(City) OVER (ORDER BY Year ASC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_city
FROM Hosts
ORDER BY ASC;

-- Exercises:
WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000)

SELECT
  -- For each year, fetch the current and future medalists
  Athlete,
  Year,
  LEAD(Athlete, 3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;

WITH All_Male_Medalists AS (
  SELECT DISTINCT
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Gender = 'Men')

SELECT
  -- Fetch all athletes and the first athlete alphabetically
  Athlete,
  FIRST_VALUE(Athlete) OVER (
    ORDER BY Athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

WITH Hosts AS (
  SELECT DISTINCT Year, City
    FROM Summer_Medals)

SELECT
  Year,
  City,
  -- Get the last city in which the Olympic games were held
  LAST_VALUE(City) OVER (
   ORDER BY Year ASC
   RANGE BETWEEN
     UNBOUNDED PRECEDING AND
     UNBOUNDED FOLLOWING
  ) AS Last_City
FROM Hosts
ORDER BY Year ASC;

-- Ranking
ROW_NUMBER -- always assigns unique numbers, even if two row's values are the same
RANK() -- assigns the same number to rwos with identical values, skipping over the next numbers
DENSE_RANK() -- assigns the same number to rows, but does not skip over next numbers

WITH Country_games AS (
    SELECT Country, COUNT(DISTINCT Year) AS games
    FROM Summer_Medals
    WHERE 
        Country IN ('GBR', 'DEN', 'FRA', 'ITA')
    GROUP BY Country
    ORDER BY Games DESC)
SELECT Country, Games,
    ROW_NUMBER() OVER (ORDER BY Games DESC) AS Row_N
FROM Country_games
ORDER BY Games DESC, Country ASC;

WITH Country_games AS (
    SELECT Country, COUNT(DISTINCT Year) AS games
    FROM Summer_Medals
    WHERE 
        Country IN ('GBR', 'DEN', 'FRA', 'ITA')
    GROUP BY Country
    ORDER BY Games DESC)
SELECT Country, Games,
    ROW_NUMBER() OVER (ORDER BY Games DESC) AS Row_N,
    RANK() OVER (ORDER BY Games DESC) AS Rank_N
FROM Country_games
ORDER BY Games DESC, Country ASC;

WITH Country_games AS (
    SELECT Country, COUNT(DISTINCT Year) AS games
    FROM Summer_Medals
    WHERE 
        Country IN ('GBR', 'DEN', 'FRA', 'ITA')
    GROUP BY Country
    ORDER BY Games DESC)
SELECT Country, Games,
    ROW_NUMBER() OVER (ORDER BY Games DESC) AS Row_N,
    RANK() OVER (ORDER BY Games DESC) AS Rank_N,
    DENSE_RANK() OVER (ORDER BY Games DESC) AS Dense_Rank_N
FROM Country_games
ORDER BY Games DESC, Country ASC;

-- Ranking without partitioning

SELECT Country, Athlete, COUNT(*) AS Medals
FROM Summer_Medals
WHERE Country IN ('CHN', 'RUS')
    AND Year = 2012
GROUP BY Country, Athlete
HAVING COUNT(*) > 1
ORDER BY Country ASC, Medals DESC;

-- Make sure to partition by country if you want athletes to be ranked by country, not ranked by total dataset
WITH Country_medals AS (
   SELECT Country, Athlete, COUNT(*) AS Medals
        FROM Summer_Medals
        WHERE Country IN ('CHN', 'RUS')
            AND Year = 2012
        GROUP BY Country, Athlete
        HAVING COUNT(*) > 1
        ORDER BY Country ASC, Medals DESC; 
)
SELECT
    Country, Athlete, Medals,
    DENSE_RANK() OVER (ORDER BY Medals DESC) AS Rank_N
FROM Country_medals
ORDER BY Country ASC, Medals DESC;

-- Instead, you should do it like this:

WITH Country_medals AS (
   SELECT Country, Athlete, COUNT(*) AS Medals
        FROM Summer_Medals
        WHERE Country IN ('CHN', 'RUS')
            AND Year = 2012
        GROUP BY Country, Athlete
        HAVING COUNT(*) > 1
        ORDER BY Country ASC, Medals DESC; 
)
SELECT
    Country, Athlete,
    DENSE_RANK() OVER (
        PARTITION BY Country
        ORDER BY Medals DESC) AS Rank_N
FROM Country_medals
ORDER BY Country ASC, Medals DESC;

-- Exercises:

WITH Athlete_Medals AS (
  SELECT
    Athlete,
    COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete)

SELECT
  Athlete,
  Medals,
  -- Rank athletes by the medals they've won
  RANK() OVER (ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Medals DESC;

WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('JPN', 'KOR')
    AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)

SELECT
  Country,
  -- Rank athletes in each country by the medals they've won
  Athlete,
  DENSE_RANK() OVER (PARTITION BY Country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;

-- Paging
