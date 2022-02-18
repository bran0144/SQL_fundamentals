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

