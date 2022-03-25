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
-- Splits data into approximately equal chunks
-- Helpful with API's
-- Separating data into quartiles or thirds can help judge performance
NTILE(n) -- splits the data into n approximately euqal pages

WITH Disciplines AS (
    SELECT DISTINCT Discipline
    FROM Summer_Medals
)
SELECT Discipline, NTILE(15) OVER () AS Page 
FROM Disciplines
ORDER BY Page ASC;

-- Splitting into thirds
WITH Country_medals AS (
    SELECT Country, COUNT(*) AS Medals
    FROM Summer_Medals
    GROUP_BY Country
),
SELECT Country, Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third 
FROM Country_Medals;

-- Thirds Averages
WITH Country_medals AS (
    SELECT Country, COUNT(*) AS Medals
    FROM Summer_Medals
    GROUP_BY Country),

    Thirds AS (
        SELECT Country, Medals,
            NTILE(3) OVER (ORDER BY Medals DESC) AS Third 
        FROM Country_Medals)

SELECT Third, ROUND(AVG(Medals), 2) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;

-- Exercises:

WITH Events AS (
  SELECT DISTINCT Event
  FROM Summer_Medals)
  
SELECT
  --- Split up the distinct events into 111 unique groups
  Event,
  NTILE(111) OVER (ORDER BY Event ASC) AS Page
FROM Events
ORDER BY Event ASC;


WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1)
  
SELECT
  Athlete,
  Medals,
  -- Split athletes into thirds by their earned medals
  NTILE(3) OVER (ORDER BY Medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;


WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1),
  
  Thirds AS (
  SELECT
    Athlete,
    Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third
  FROM Athlete_Medals)
  
SELECT
  -- Get the average medals earned in each third
  Third,
  AVG(Medals) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;

-- Aggregate window functions
WITH Brazil_Medals AS (
    SELECT Year, COUNT(*) AS Medals
    FROM Summer_Medals
    WHERE Country = 'BRA'
        AND Medal = 'Gold'
        AND Year >= 1992
    GROUP BY Year 
    ORDER BY Year ASC
)
SELECT Year, Medals, 
    MAX(Medals) OVER (ORDER BY Year ASC) AS Max_Medals
FROM Brazil_Medals;


WITH Brazil_Medals AS (
    SELECT Year, COUNT(*) AS Medals
    FROM Summer_Medals
    WHERE Country = 'BRA'
        AND Medal = 'Gold'
        AND Year >= 1992
    GROUP BY Year 
    ORDER BY Year ASC
)
SELECT Year, Medals, 
    SUM(Medals) OVER (ORDER BY Year ASC) AS Medals_RT
FROM Brazil_Medals;

-- Need to partition to sum by country
WITH Medals AS (...)
SELECT Year, Country, Medals,
    SUM(Medals) OVER (PARTITION BY Country ...)
FROM Medals;

WITH Athlete_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'USA' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Calculate the running total of athlete medals
  Athlete,
  Medals,
  SUM(Medals) OVER (ORDER BY Athlete ASC) AS Max_Medals
FROM Athlete_Medals
ORDER BY Athlete ASC;

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country)

SELECT
  -- Return the max medals earned so far per country
  Year,
  Country,
  Medals,
  MAX(Medals) OVER (PARTITION BY Country
                ORDER BY Year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

WITH France_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'FRA'
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year)

SELECT
  Year,
  Medals,
  MIN(Medals) OVER (ORDER BY Year ASC) AS Min_Medals
FROM France_Medals
ORDER BY Year ASC;

-- Frames
-- Using ROWS BETWEEN [START] AND [FINISH]
-- n PRECEDING - n rows before the current row
-- CURRENT ROW
-- n FOLLOWING - n rows after the current row

ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING

-- Exercises:

WITH Scandinavian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('DEN', 'NOR', 'FIN', 'SWE', 'ISL')
    AND Medal = 'Gold'
  GROUP BY Year)

SELECT
  -- Select each year's medals
  Year,
  Medals,
  -- Get the max of the current and next years'  medals
  MAX(Medals) OVER (ORDER BY Year ASC
             ROWS BETWEEN CURRENT ROW
             AND 1 FOLLOWING) AS Max_Medals
FROM Scandinavian_Medals
ORDER BY Year ASC;

WITH Chinese_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'CHN' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Select the athletes and the medals they've earned
  Athlete,
  Medals,
  -- Get the max of the last two and current rows' medals 
  MAX(Medals) OVER (ORDER BY Athlete ASC
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW) AS Max_Medals
FROM Chinese_Medals
ORDER BY Athlete ASC;

-- Moving Averages
    -- Used to indicate momentum/trends
    -- help to eliminate seasonality
-- Moving Totals
    -- used to indicate performance

WITH US_Medals AS (...)
SELECT Year, Medals,
    AVG(Medals) OVER (ORDER BY Year ASC
        ROWS BETWEEN
        2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM US_Medals
ORDER BY Year ASC;

WITH US_Medals AS (...)
SELECT Year, Medals,
    SUM(Medals) OVER (ORDER BY Year ASC
        ROWS BETWEEN
        2 PRECEDING AND CURRENT ROW) AS Medals_MT
FROM US_Medals
ORDER BY Year ASC;

-- Range between - treats duplicates in OVER's subclause as a single entity
-- Rows does not
-- ROWS is almost always used over ROWS Between

-- Exercises
WITH Russian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'RUS'
    AND Medal = 'Gold'
    AND Year >= 1980
  GROUP BY Year)

SELECT
  Year, Medals,
  --- Calculate the 3-year moving average of medals earned
  AVG(Medals) OVER
    (ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Russian_Medals
ORDER BY Year ASC;

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Year, Country)

SELECT
  Year, Country, Medals,
  -- Calculate each country's 3-game moving total
  SUM(Medals) OVER
    (PARTITION BY Country
     ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

-- Pivoting
-- CROSSTAB lets you pivot a table by a column - makes them easier to read, depending on the column
CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT * FROM CROSSTAB($$
    source_sql TEXT
$$) AS ct (column_1 DATA_TYPE_1, 
            column_2 DATA_TYPE_2);

CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT * FROM CROSSTAB($$
    SELECT
        Country, Year, COUNT(*) :: INTEGER AS Awards
    FROM Summer_Medals
    WHERE
        Country IN ('CHN', 'RUS', 'USA')
        AND Year IN (2008, 2012)
        AND Medal = 'Gold'
    GROUP BY Country, Year
    ORDER BY Country ASC, Year, ASC;
$$) AS ct (Country VARCHAR, "2008" INTEGER, "2012" INTEGER)
ORDER BY Country Asc;

-- Pivoting with window functions
WITH Country_Awards AS (
    SELECT
        Country, Year, COUNT(*) AS Awards
    FROM Summer_Medals
    WHERE Country IN ('CHN', 'RUS', 'USA')
        AND Year IN (2004, 2008, 2012)
        AND Medal = 'Gold' AND Sport = 'Gymnastics'
    GROUP BY Country, Year
    ORDER BY Country ASC, Year, ASC)
SELECT Country, Year
    RANK() OVER 
        (PARTITION BY Year ORDER BY Awards DESC) :: INTEGER AS rank
FROM Country_Awards
ORDER BY Country ASC, Year ASC;

-- Exercises:
-- Create the correct extention to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           Medal VARCHAR,
           Event VARCHAR)

ORDER BY Gender ASC;

-- Count the gold medals per country and year
SELECT
  Country,
  Year,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Country IN ('FRA', 'GBR', 'GER')
  AND Year IN (2004, 2008, 2012)
  AND Medal = 'Gold'
GROUP BY Country, Year
ORDER BY Country ASC, Year ASC

WITH Country_Awards AS (
  SELECT
    Country,
    Year,
    COUNT(*) AS Awards
  FROM Summer_Medals
  WHERE
    Country IN ('FRA', 'GBR', 'GER')
    AND Year IN (2004, 2008, 2012)
    AND Medal = 'Gold'
  GROUP BY Country, Year)

SELECT
  -- Select Country and Year
  Country,
  Year,
  -- Rank by gold medals earned per year
  RANK() OVER (PARTITION BY Year ORDER BY Awards) :: INTEGER AS rank
FROM Country_Awards
ORDER BY Country ASC, Year ASC;

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM Summer_Medals
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)

  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)

Order by Country ASC;

-- ROLLUP and CUBE
-- ROLLUP includes extra rows for group-level aggregations
SELECT
    Country, Medal, COUNT(*) AS Awards
FROM Summer_Medals
WHERE  
    Year = 2008 AND Country IN ('CHN', 'RUS')
GROUP BY Country, ROLLUP(Medal)
ORDER BY Country ASC, Medal ASC;

-- ROLLUP can also generate grand totals
SELECT
    Country, Medal, COUNT(*) AS Awards
FROM Summer_Medals
WHERE  
    Year = 2008 AND Country IN ('CHN', 'RUS')
GROUP BY Country, ROLLUP(Country, Medal)
ORDER BY Country ASC, Medal ASC;
-- ROLLUP is hierarchical - 
    -- ROLLUP(Country, Medal) - includes Country level totals
    -- ROLLUP(Medals, Country) - includes Medal level totals
    -- Both include grand totals
    -- group level totals contain nulls
    -- the row with all nulls is hte grand total
-- CUBE - similar to ROLLLUP but not hierarchical
SELECT
    Country, Medal, COUNT(*) AS Awards
FROM Summer_Medals
WHERE  
    Year = 2008 AND Country IN ('CHN', 'RUS')
GROUP BY CUBE(Country, Medal)
ORDER BY Country ASC, Medal ASC;

-- generates all possible group level aggregations
-- country, level, medal level, and grand totals

-- Exercises:
-- Count the gold medals per country and gender
SELECT
  Country,
  Gender,
  COUNT(*) AS Gold_Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
-- Generate Country-level subtotals
GROUP BY Country, ROLLUP(Gender)
ORDER BY Country ASC, Gender ASC;

-- Count the medals per country and medal type
SELECT
  Gender,
  Medal,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2012
  AND Country = 'RUS'
-- Get all possible group-level subtotals
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;

-- Useful Functions
-- COALESCE - will replace null values to indicate group totals
SELECT
    COALESCE(Country, 'Both countries') AS Country,
    COALESCE(Medal, 'All medals') AS Medal,
    COUNT(*) AS Awards
FROM Summer_Medals
WHERE  
    Year = 2008 AND Country IN ('CHN', 'RUS')
GROUP BY ROLLUP(Country, Medal)
ORDER BY Country ASC, Medal ASC;

-- compressing data
-- if you sort by rank, the rank becomes redundant because ranking is implied
-- STRING_AGG(column, separator) - takes all values of a column and concatenates them with a separator

WITH Country_Medals AS (...),
    Country_Ranks AS (...)
    SELECT STRING_AGG(country, ', ')
    FROM Country_Medals;

-- Exercises:
SELECT
  -- Replace the nulls in the columns with meaningful text
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
GROUP BY ROLLUP(Country, Gender)
ORDER BY Country ASC, Gender ASC;

WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country)

  SELECT
    Country,
    -- Rank countries by the medals awarded
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC;

WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country),

  Country_Ranks AS (
  SELECT
    Country,
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC)

-- Compress the countries column
SELECT STRING_AGG(Country, ', ')
FROM Country_Ranks
-- Select only the top three ranks
WHERE Rank <= 3;
