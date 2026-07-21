-- Run with: psql < outer_space.sql

DROP DATABASE IF EXISTS outer_space;
CREATE DATABASE outer_space;
\c outer_space

CREATE TABLE galaxies (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE stars (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  galaxy_id INTEGER NOT NULL REFERENCES galaxies(id),
  UNIQUE (name, galaxy_id)
);

CREATE TABLE planets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  orbital_period_in_years NUMERIC(10, 4) NOT NULL CHECK (orbital_period_in_years > 0),
  star_id INTEGER NOT NULL REFERENCES stars(id),
  UNIQUE (name, star_id)
);

CREATE TABLE moons (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  planet_id INTEGER NOT NULL REFERENCES planets(id),
  UNIQUE (name, planet_id)
);

INSERT INTO galaxies (name) VALUES ('Milky Way');
INSERT INTO stars (name, galaxy_id)
SELECT star_name, g.id
FROM (VALUES ('The Sun'), ('Proxima Centauri'), ('Gliese 876')) AS s(star_name)
CROSS JOIN galaxies AS g
WHERE g.name = 'Milky Way';

INSERT INTO planets (name, orbital_period_in_years, star_id)
SELECT p.name, p.period, s.id
FROM (VALUES
  ('Earth', 1.00::NUMERIC, 'The Sun'),
  ('Mars', 1.88::NUMERIC, 'The Sun'),
  ('Venus', 0.62::NUMERIC, 'The Sun'),
  ('Neptune', 164.8::NUMERIC, 'The Sun'),
  ('Proxima Centauri b', 0.03::NUMERIC, 'Proxima Centauri'),
  ('Gliese 876 b', 0.23::NUMERIC, 'Gliese 876')
) AS p(name, period, star_name)
JOIN stars AS s ON s.name = p.star_name;

INSERT INTO moons (name, planet_id)
SELECT m.name, p.id
FROM (VALUES
  ('The Moon', 'Earth'), ('Phobos', 'Mars'), ('Deimos', 'Mars'),
  ('Naiad', 'Neptune'), ('Thalassa', 'Neptune'), ('Despina', 'Neptune'),
  ('Galatea', 'Neptune'), ('Larissa', 'Neptune'), ('S/2004 N 1', 'Neptune'),
  ('Proteus', 'Neptune'), ('Triton', 'Neptune'), ('Nereid', 'Neptune'),
  ('Halimede', 'Neptune'), ('Sao', 'Neptune'), ('Laomedeia', 'Neptune'),
  ('Psamathe', 'Neptune'), ('Neso', 'Neptune')
) AS m(name, planet_name)
JOIN planets AS p ON p.name = m.planet_name;
