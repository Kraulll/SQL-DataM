-- Run with $ psql < air_traffic.sql
DROP DATABASE IF EXISTS air_traffic;
CREATE DATABASE air_traffic;
\c air_traffic

CREATE TABLE passengers (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  UNIQUE (first_name, last_name)
);

CREATE TABLE airlines (id SERIAL PRIMARY KEY, name TEXT NOT NULL UNIQUE);
CREATE TABLE countries (id SERIAL PRIMARY KEY, name TEXT NOT NULL UNIQUE);
CREATE TABLE cities (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  country_id INTEGER NOT NULL REFERENCES countries(id),
  UNIQUE (name, country_id)
);

CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  airline_id INTEGER NOT NULL REFERENCES airlines(id),
  departure TIMESTAMP NOT NULL,
  arrival TIMESTAMP NOT NULL CHECK (arrival > departure),
  origin_city_id INTEGER NOT NULL REFERENCES cities(id),
  destination_city_id INTEGER NOT NULL REFERENCES cities(id),
  CHECK (origin_city_id <> destination_city_id),
  UNIQUE (airline_id, departure, origin_city_id, destination_city_id)
);

CREATE TABLE tickets (
  id SERIAL PRIMARY KEY,
  passenger_id INTEGER NOT NULL REFERENCES passengers(id),
  flight_id INTEGER NOT NULL REFERENCES flights(id),
  seat TEXT NOT NULL,
  UNIQUE (flight_id, seat),
  UNIQUE (passenger_id, flight_id)
);

INSERT INTO passengers (first_name, last_name) VALUES
  ('Jennifer', 'Finch'), ('Thadeus', 'Gathercoal'), ('Sonja', 'Pauley'),
  ('Waneta', 'Skeleton'), ('Berkie', 'Wycliff'), ('Alvin', 'Leathes'), ('Cory', 'Squibbes');
INSERT INTO airlines (name) VALUES
  ('United'), ('British Airways'), ('Delta'), ('TUI Fly Belgium'), ('Air China'), ('American Airlines'), ('Avianca Brasil');
INSERT INTO countries (name) VALUES
  ('United States'), ('Japan'), ('United Kingdom'), ('Mexico'), ('France'), ('Morocco'), ('UAE'), ('China'), ('Brazil'), ('Chile');
INSERT INTO cities (name, country_id)
SELECT x.city, c.id FROM (VALUES
  ('Washington DC', 'United States'), ('Seattle', 'United States'), ('Tokyo', 'Japan'), ('London', 'United Kingdom'),
  ('Los Angeles', 'United States'), ('Las Vegas', 'United States'), ('Mexico City', 'Mexico'), ('Paris', 'France'),
  ('Casablanca', 'Morocco'), ('Dubai', 'UAE'), ('Beijing', 'China'), ('New York', 'United States'),
  ('Charlotte', 'United States'), ('Cedar Rapids', 'United States'), ('Chicago', 'United States'),
  ('New Orleans', 'United States'), ('Sao Paolo', 'Brazil'), ('Santiago', 'Chile')
) AS x(city, country) JOIN countries AS c ON c.name = x.country;

CREATE TEMP TABLE ticket_seed (first_name TEXT, last_name TEXT, seat TEXT, departure TIMESTAMP, arrival TIMESTAMP, airline TEXT, origin TEXT, destination TEXT);
INSERT INTO ticket_seed VALUES
  ('Jennifer','Finch','33B','2018-04-08 09:00','2018-04-08 12:00','United','Washington DC','Seattle'),
  ('Thadeus','Gathercoal','8A','2018-12-19 12:45','2018-12-19 16:15','British Airways','Tokyo','London'),
  ('Sonja','Pauley','12F','2018-01-02 07:00','2018-01-02 08:03','Delta','Los Angeles','Las Vegas'),
  ('Jennifer','Finch','20A','2018-04-15 16:50','2018-04-15 21:00','Delta','Seattle','Mexico City'),
  ('Waneta','Skeleton','23D','2018-08-01 18:30','2018-08-01 21:50','TUI Fly Belgium','Paris','Casablanca'),
  ('Thadeus','Gathercoal','18C','2018-10-31 01:15','2018-10-31 12:55','Air China','Dubai','Beijing'),
  ('Berkie','Wycliff','9E','2019-02-06 06:00','2019-02-06 07:47','United','New York','Charlotte'),
  ('Alvin','Leathes','1A','2018-12-22 14:42','2018-12-22 15:56','American Airlines','Cedar Rapids','Chicago'),
  ('Berkie','Wycliff','32B','2019-02-06 16:28','2019-02-06 19:18','American Airlines','Charlotte','New Orleans'),
  ('Cory','Squibbes','10D','2019-01-20 19:30','2019-01-20 22:45','Avianca Brasil','Sao Paolo','Santiago');

INSERT INTO flights (airline_id, departure, arrival, origin_city_id, destination_city_id)
SELECT a.id, t.departure, t.arrival, o.id, d.id FROM ticket_seed t
JOIN airlines a ON a.name = t.airline JOIN cities o ON o.name = t.origin JOIN cities d ON d.name = t.destination;
INSERT INTO tickets (passenger_id, flight_id, seat)
SELECT p.id, f.id, t.seat FROM ticket_seed t
JOIN passengers p ON (p.first_name, p.last_name) = (t.first_name, t.last_name)
JOIN airlines a ON a.name = t.airline JOIN cities o ON o.name = t.origin JOIN cities d ON d.name = t.destination
JOIN flights f ON (f.airline_id, f.departure, f.origin_city_id, f.destination_city_id) = (a.id, t.departure, o.id, d.id);
