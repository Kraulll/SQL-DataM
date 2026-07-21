-- Run with: psql < music.sql

DROP DATABASE IF EXISTS music;
CREATE DATABASE music;
\c music

CREATE TABLE people (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE albums (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL UNIQUE
);

CREATE TABLE songs (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  duration_in_seconds INTEGER NOT NULL CHECK (duration_in_seconds > 0),
  release_date DATE NOT NULL,
  album_id INTEGER NOT NULL REFERENCES albums(id),
  UNIQUE (title, album_id)
);

CREATE TABLE song_artists (
  song_id INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  person_id INTEGER NOT NULL REFERENCES people(id),
  PRIMARY KEY (song_id, person_id)
);

CREATE TABLE song_producers (
  song_id INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  person_id INTEGER NOT NULL REFERENCES people(id),
  PRIMARY KEY (song_id, person_id)
);

INSERT INTO people (name) VALUES
  ('Hanson'), ('Dust Brothers'), ('Stephen Lironi'), ('Queen'), ('Roy Thomas Baker'),
  ('Mariah Carey'), ('Boyz II Men'), ('Walter Afanasieff'), ('Lady Gaga'),
  ('Bradley Cooper'), ('Benjamin Rice'), ('Nickelback'), ('Rick Parashar'),
  ('Jay Z'), ('Alicia Keys'), ('Al Shux'), ('Katy Perry'), ('Juicy J'),
  ('Max Martin'), ('Cirkut'), ('Maroon 5'), ('Christina Aguilera'), ('Shellback'),
  ('Benny Blanco'), ('Avril Lavigne'), ('The Matrix'), ('Destiny''s Child'), ('Darkchild');

INSERT INTO albums (title) VALUES
  ('Middle of Nowhere'), ('A Night at the Opera'), ('Daydream'), ('A Star Is Born'),
  ('Silver Side Up'), ('The Blueprint 3'), ('Prism'), ('Hands All Over'), ('Let Go'),
  ('The Writing''s on the Wall');

INSERT INTO songs (title, duration_in_seconds, release_date, album_id)
SELECT s.title, s.duration, s.release_date, a.id
FROM (VALUES
  ('MMMBop', 238, DATE '1997-04-15', 'Middle of Nowhere'),
  ('Bohemian Rhapsody', 355, DATE '1975-10-31', 'A Night at the Opera'),
  ('One Sweet Day', 282, DATE '1995-11-14', 'Daydream'),
  ('Shallow', 216, DATE '2018-09-27', 'A Star Is Born'),
  ('How You Remind Me', 223, DATE '2001-08-21', 'Silver Side Up'),
  ('New York State of Mind', 276, DATE '2009-10-20', 'The Blueprint 3'),
  ('Dark Horse', 215, DATE '2013-12-17', 'Prism'),
  ('Moves Like Jagger', 201, DATE '2011-06-21', 'Hands All Over'),
  ('Complicated', 244, DATE '2002-05-14', 'Let Go'),
  ('Say My Name', 240, DATE '1999-11-07', 'The Writing''s on the Wall')
) AS s(title, duration, release_date, album_title)
JOIN albums AS a ON a.title = s.album_title;

INSERT INTO song_artists (song_id, person_id)
SELECT s.id, p.id FROM (VALUES
  ('MMMBop', 'Hanson'), ('Bohemian Rhapsody', 'Queen'),
  ('One Sweet Day', 'Mariah Carey'), ('One Sweet Day', 'Boyz II Men'),
  ('Shallow', 'Lady Gaga'), ('Shallow', 'Bradley Cooper'), ('How You Remind Me', 'Nickelback'),
  ('New York State of Mind', 'Jay Z'), ('New York State of Mind', 'Alicia Keys'),
  ('Dark Horse', 'Katy Perry'), ('Dark Horse', 'Juicy J'), ('Moves Like Jagger', 'Maroon 5'),
  ('Moves Like Jagger', 'Christina Aguilera'), ('Complicated', 'Avril Lavigne'),
  ('Say My Name', 'Destiny''s Child')
) AS x(song_title, person_name)
JOIN songs AS s ON s.title = x.song_title JOIN people AS p ON p.name = x.person_name;

INSERT INTO song_producers (song_id, person_id)
SELECT s.id, p.id FROM (VALUES
  ('MMMBop', 'Dust Brothers'), ('MMMBop', 'Stephen Lironi'), ('Bohemian Rhapsody', 'Roy Thomas Baker'),
  ('One Sweet Day', 'Walter Afanasieff'), ('Shallow', 'Benjamin Rice'), ('How You Remind Me', 'Rick Parashar'),
  ('New York State of Mind', 'Al Shux'), ('Dark Horse', 'Max Martin'), ('Dark Horse', 'Cirkut'),
  ('Moves Like Jagger', 'Shellback'), ('Moves Like Jagger', 'Benny Blanco'),
  ('Complicated', 'The Matrix'), ('Say My Name', 'Darkchild')
) AS x(song_title, person_name)
JOIN songs AS s ON s.title = x.song_title JOIN people AS p ON p.name = x.person_name;
