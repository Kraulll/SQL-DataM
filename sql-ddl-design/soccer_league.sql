-- Run with: psql < soccer_league.sql
DROP DATABASE IF EXISTS soccer_league;
CREATE DATABASE soccer_league;
\c soccer_league

CREATE TABLE leagues (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE seasons (
  id SERIAL PRIMARY KEY,
  league_id INTEGER NOT NULL REFERENCES leagues(id),
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL CHECK (ends_on >= starts_on),
  UNIQUE (league_id, starts_on)
);

CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  league_id INTEGER NOT NULL REFERENCES leagues(id),
  name TEXT NOT NULL,
  UNIQUE (league_id, name)
);

CREATE TABLE players (
  id SERIAL PRIMARY KEY,
  team_id INTEGER NOT NULL REFERENCES teams(id),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  jersey_number INTEGER CHECK (jersey_number BETWEEN 1 AND 99),
  UNIQUE (team_id, jersey_number)
);

CREATE TABLE referees (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL
);

CREATE TABLE matches (
  id SERIAL PRIMARY KEY,
  season_id INTEGER NOT NULL REFERENCES seasons(id),
  home_team_id INTEGER NOT NULL REFERENCES teams(id),
  away_team_id INTEGER NOT NULL REFERENCES teams(id),
  started_at TIMESTAMP NOT NULL,
  CHECK (home_team_id <> away_team_id)
);

CREATE TABLE match_referees (
  match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  referee_id INTEGER NOT NULL REFERENCES referees(id),
  PRIMARY KEY (match_id, referee_id)
);

-- One row per goal; minute_scored permits a game-by-game player goal total.
CREATE TABLE goals (
  id SERIAL PRIMARY KEY,
  match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  player_id INTEGER NOT NULL REFERENCES players(id),
  minute_scored INTEGER NOT NULL CHECK (minute_scored BETWEEN 0 AND 130),
  is_own_goal BOOLEAN NOT NULL DEFAULT FALSE
);

-- Standings are derivable from matches and goals, rather than stored redundantly.
CREATE VIEW team_standings AS
WITH scored AS (
  SELECT m.id, m.season_id, m.home_team_id, m.away_team_id,
         COUNT(g.id) FILTER (WHERE p.team_id = m.home_team_id AND NOT g.is_own_goal)
           + COUNT(g.id) FILTER (WHERE p.team_id = m.away_team_id AND g.is_own_goal) AS home_goals,
         COUNT(g.id) FILTER (WHERE p.team_id = m.away_team_id AND NOT g.is_own_goal)
           + COUNT(g.id) FILTER (WHERE p.team_id = m.home_team_id AND g.is_own_goal) AS away_goals
  FROM matches m
  LEFT JOIN goals g ON g.match_id = m.id
  LEFT JOIN players p ON p.id = g.player_id
  GROUP BY m.id
), results AS (
  SELECT season_id, home_team_id AS team_id, home_goals AS goals_for, away_goals AS goals_against,
         CASE WHEN home_goals > away_goals THEN 3 WHEN home_goals = away_goals THEN 1 ELSE 0 END AS points
  FROM scored
  UNION ALL
  SELECT season_id, away_team_id, away_goals, home_goals,
         CASE WHEN away_goals > home_goals THEN 3 WHEN away_goals = home_goals THEN 1 ELSE 0 END
  FROM scored
)
SELECT season_id, team_id, COUNT(*) AS matches_played, SUM(points) AS points,
       SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against,
       SUM(goals_for - goals_against) AS goal_difference,
       RANK() OVER (PARTITION BY season_id ORDER BY SUM(points) DESC, SUM(goals_for - goals_against) DESC, SUM(goals_for) DESC) AS rank
FROM results
GROUP BY season_id, team_id;
