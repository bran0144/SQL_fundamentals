SELECT
    l.name AS league,
    COUNT(m.country_id) as matches
FROM league as l
LEFT JOIN match AS m
ON l.country_id = m.country_id
GROUP BY l.name;

-- gives you the number of matches in each of the leagues in the leagues table

SELECT
    date,
    id,
    home_goal,
    away_goal
FROM match
WHERE season = '2013/2014'
    AND home_team_goal > away_team_goal;

-- to compare home team wins, away team wins, and ties
-- not a very efficient way to do this
-- CASE statements make this easier (WHEN, THEN, ELSE)
-- this will evaluate to one column in the new table

CASE WHEN x=1 THEN 'A'
    WHEN x=2 THEN 'B'
    ELSE 'C' END AS new_column

SELECT
    id,
    home_goal,
    away_goal
    CASE WHEN home_goal > away_goal THEN "Home Team Win"
        WHEN home_goal < away_goal THEN "Away Team Win"
        ELSE "Tie" END AS outcome
FROM match
WHERE season = '2013/2014';

-- Exercises:

SELECT
	-- Select the team long name and team API id
	team_long_name,
	team_api_id
FROM teams_germany
-- Only include FC Schalke 04 and FC Bayern Munich
WHERE team_long_name IN ('FC Schalke 04', 'FC Bayern Munich');

-- Identify the home team as Bayern Munich, Schalke 04, or neither
SELECT 
	CASE WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
        WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
        ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
-- Group by the CASE statement alias
GROUP BY home_team;

SELECT 
	-- Select the date of the match
	date,
	-- Identify home wins, losses, or ties
	CASE WHEN home_goal > away_goal THEN 'Home win!'
        WHEN home_goal < away_goal THEN 'Home loss :(' 
        ELSE 'Tie' END AS outcome
FROM matches_spain;

SELECT 
	m.date,
	--Select the team long name column and call it 'opponent'
	t.team_long_name AS opponent, 
	-- Complete the CASE statement with an alias
	CASE WHEN m.home_goal > away_goal THEN 'Home win!'
        WHEN m.home_goal < away_goal THEN 'Home loss :('
        ELSE 'Tie' END AS outcome
FROM matches_spain AS m
-- Left join teams_spain onto matches_spain
LEFT JOIN teams_spain AS t
ON m.awayteam_id = t.team_api_id;

SELECT 
	m.date,
	t.team_long_name AS opponent,
    -- Complete the CASE statement with an alias
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
        WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.awayteam_id = t.team_api_id
-- Filter for Barcelona as the home team
WHERE m.hometeam_id = 8634; 

-- Select matches where Barcelona was the away team
SELECT  
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal < m.away_goal THEN 'Barcelona win!'
        WHEN m.home_goal > m.away_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome
FROM matches_spain AS m
-- Join teams_spain to matches_spain
LEFT JOIN teams_spain AS t 
ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id = 8634;

-- To test multiple logical statements together use AND
-- WHERE clause is important - other wise ALL matches that don't meet the first conditions (including
-- ones without Chelsea would be included)
SELECT date, hometeam_id, awayteam_id,
	CASE WHEN hometeam_id = 8455 AND home_goal > away_goal THEN 'Chelsea home win!'
        WHEN awayteam_id = 8455 AND home_goal < away_goal THEN 'Chelsea away win!' 
        ELSE 'Loss or Tie' END AS outcome
FROM match
WHERE hometown_id = 8455 OR awayteam_id = 8455;

-- ELSE NULL - 
SELECT date,
CASE WHEN date > '2015-01-01' THEN 'More Recently'
    WHEN date > '2012-01-01' THEN 'Older'
    END AS date_category
FROM match;
SELECT date, 
CASE WHEN date > '2015-01-01' THEN 'More Recently'
    WHEN date > '2012-01-01' THEN 'Older'
    ELSE NULL END AS date_category
FROM match;

SELECT date, season,
	CASE WHEN hometeam_id = 8455 AND home_goal > away_goal THEN 'Chelsea home win!'
        WHEN awayteam_id = 8455 AND home_goal < away_goal THEN 'Chelsea away win!' 
        END AS outcome
FROM match
WHERE CASE WHEN hometeam_id = 8455 AND home_goal > away_goal THEN 'Chelsea home win!'
        WHEN awayteam_id = 8455 AND home_goal < away_goal THEN 'Chelsea away win!' 
        END IS NOT NULL;
-- This gets rid of null values and only includes Chelsea's home and away wins

-- Exercises:
SELECT 
	date,
	-- Identify the home team as Barcelona or Real Madrid
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END AS home,
    -- Identify the away team as Barcelona or Real Madrid
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END AS away
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as away,
	-- Identify all possible match outcomes
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
        WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
        ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

-- Select team_long_name and team_api_id from team
SELECT
	team_long_name,
	team_api_id
FROM teams_italy
-- Filter for team long name
WHERE team_long_name = 'Bologna';

-- Select the season and date columns
SELECT 
	season,
	date,
    -- Identify when Bologna won a match
	CASE WHEN hometeam_id = 9857 
        AND home_goal > away_goal 
        THEN 'Bologna Win'
		WHEN awayteam_id = 9857 
        AND away_goal > home_goal 
        THEN 'Bologna Win' 
		END AS outcome
FROM matches_italy;

-- Select the season, date, home_goal, and away_goal columns
SELECT 
	season,
    date,
	home_goal,
	away_goal
FROM matches_italy
WHERE 
-- Exclude games not won by Bologna
	CASE WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
		WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
		END IS NOT NULL;

-- Case statements can be used to categorize, aggregate and filter data
SELECT
    season,
    COUNT(CASE WHEN hometeam_id = 8650
            AND home_goal> away_goal
            THEN id END) AS home_wins,
    COUNT(CASE WHEN hometeam_id = 8650
            AND home_goal < away_goal
            THEN id END) AS away_wins,
FROM match
GROUP BY season;

-- Total number of goals home vs. away
SELECT
    season,
    SUM(CASE WHEN hometeam_id = 8650
            THEN home_goal END) AS home_goals,
    SUM(CASE WHEN hometeam_id = 8650
            THEN away_goal END) AS away_goals,
FROM match
GROUP BY season;

-- average number of goals home vs. away
SELECT
    season,
    ROUND(AVG(CASE WHEN hometeam_id = 8650
            THEN home_goal END),2) AS home_goals,
    ROUND(AVG(CASE WHEN hometeam_id = 8650
            THEN away_goal END),2) AS away_goals,
FROM match
GROUP BY season;

-- Percentage of wins home vs away
SELECT
    season,
    AVG(CASE WHEN hometeam_id = 8455 AND home_goal > away_goal THEN 1
            WHEN hometeam_id = 8455 AND home_goal < away_goal THEN 0
            END) AS pct_homewins,
    AVG(CASE WHEN awayteam_id = 8455 AND away_goal > home_goal THEN 1
            WHEN awayteam_id = 8455 AND away_goal < home_goal THEN 0
            END) AS pct_awaywins
FROM match
GROUP BY sesason;

-- Exercises:

SELECT 
	c.name AS country,
    -- Count games from the 2012/2013 season
	COUNT(CASE WHEN m.season = '2012/2013' 
          	   THEN m.id ELSE NULL END) AS matches_2012_2013
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country;

SELECT 
	c.name AS country,
    -- Count matches in each of the 3 seasons
	COUNT(CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
	COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
	COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country;

SELECT 
	c.name AS country,
    -- Sum the total records in each season where the home team won
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal  
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country;

SELECT 
    c.name AS country,
    -- Count the home wins, away wins, and ties in each country
	COUNT(CASE WHEN m.home_goal > m.away_goal THEN m.id 
        END) AS home_wins,
	COUNT(CASE WHEN m.home_goal < m.away_goal THEN m.id 
        END) AS away_wins,
	COUNT(CASE WHEN m.home_goal = m.away_goal THEN m.id 
        END) AS ties
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

SELECT 
	c.name AS country,
    -- Calculate the percentage of tied games in each season
	AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2013_2014,
	AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

SELECT 
	c.name AS country,
    -- Round the percentage of tied games to 2 decimal points
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

-- Subqueries
-- another select statement within your query
-- Useful for intermediary transformations
-- can be placed in any part of query (in select, from, where, group by)
-- depends on what you want the final data to look like
-- can return scalar quantities, a list, a table
-- come use cases (comparing groups to summarized values, reshaping data, combine data that can't be joined)

SELECT home_goal
FROM match
WHERE home_goal > (
        SELECT AVG(home_goal)
        FROM match);

-- Simple subqueries are only processed once in the entire statement
-- subqueries are processed first

-- in the WHERE clause
-- good for filtering
-- can only return a single column
SELECT date, hometeam_id, awayteam_id, home_goal, away_goal
FROM match
WHERE season = '2012/2013'
        AND home_goal > (SELECT AVG(home_goal)
                FROM match);

-- can filter in with IN in the WHERE clause
SELECT team_long_name, team_short_name AS abbr
FROM team
WHERE team_api_id IN (SELECT hometeam_id
        FROM match
        WHERE country_id = 15722);

-- Exercises:
-- Select the average of home + away goals, multiplied by 3
SELECT 
	3 * AVG(home_goal + away_goal)
FROM matches_2013_2014;

SELECT 
	-- Select the date, home goals, and away goals scored
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014
-- Filter for matches where total goals exceeds 3x the average
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 

SELECT 
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM team 
-- Exclude all values from the subquery
WHERE team_api_id NOT IN
     (SELECT DISTINCT hometeam_ID  FROM match);

SELECT
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM team
-- Filter for teams with 8 or more home goals
WHERE team_api_id IN
	  (SELECT hometeam_id 
       FROM match
       WHERE home_goal >= 8);

-- FROM clause
-- good for restructuring or transforming your data
-- good for prefiltering or going from long to wide
-- good for calculating aggregates of aggregates

SELECT team, home_avg
FROM (SELECT
                t.team_long_name AS team,
                AVG(m.home_goal) AS home_age
        FROM match as m
        LEFT JOIN team AS t
        ON m.hometeam_id = t.team_api_id
        WHERE season = '2011/2012'
        GROUP BY team) AS subquery
ORDER BY home_avg DESC
LIMIT 3;

-- You can create multiple subqueries in one FROM statement
-- BUT, you need to alias them and join them to each other
-- You can joing a subquery to an existing table
-- BUT, you need to have a column in existing table that you can join to

-- Exercises

SELECT 
	-- Select the country ID and match ID
	country_id, 
    id
FROM match
-- Filter for matches with 10 or more goals in total
WHERE (home_goal + away_goal) >= 10;

SELECT
	-- Select country name and the count match IDs
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
INNER JOIN (SELECT country_id, id 
           FROM match
           -- Filter the subquery by matches with 10+ goals
           WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name;

SELECT
	-- Select country, date, home, and away goals from the subquery
    country,
    date,
    home_goal,
    away_goal
FROM 
	-- Select country name, date, home_goal, away_goal, and total goals in the subquery
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_goal, 
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >= 10;

-- Subqueries In SELECT
-- Useful for complex math calculations
-- subquery needs to return a single value
-- make sure you have filters in the right places (need where clause in both)

SELECT 
        season, 
        COUNT(id) AS matches,
        (SELECT COUNT(id) FROM match) as total_matches
FROM match
GROUP BY season;

SELECT
        date,
        (home_goal + away_goal) AS goals,
        (home_goal + away_goal) - 
        (SELECT AVG(home_goal + away_goal)
        FROM match
        WHERE season = '2011/2012') AS diff
FROM match
WHERE season = '2011/2012';

-- Exercises

SELECT 
	l.name AS league,
    -- Select and round the league's total goals
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    -- Select & round the average total goals for the season
    (SELECT ROUND(AVG(home_goal + away_goal), 2) 
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE season = '2013/2014'
GROUP BY l.name;

SELECT
	-- Select the league name and average goals scored
	l.name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE m.season = '2013/2014'
GROUP BY l.name;

