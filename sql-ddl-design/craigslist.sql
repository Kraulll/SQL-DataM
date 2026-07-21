-- Run with: psql < craigslist.sql
DROP DATABASE IF EXISTS craigslist;
CREATE DATABASE craigslist;
\c craigslist

CREATE TABLE regions (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  preferred_region_id INTEGER REFERENCES regions(id)
);

CREATE TABLE locations (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  region_id INTEGER NOT NULL REFERENCES regions(id),
  UNIQUE (name, region_id),
  UNIQUE (id, region_id)
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  region_id INTEGER NOT NULL REFERENCES regions(id),
  location_id INTEGER NOT NULL,
  FOREIGN KEY (location_id, region_id) REFERENCES locations(id, region_id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

-- A post can appear in more than one category.
CREATE TABLE post_categories (
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  PRIMARY KEY (post_id, category_id)
);
