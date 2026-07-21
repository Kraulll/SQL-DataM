-- Run with: psql < medical_center.sql
DROP DATABASE IF EXISTS medical_center;
CREATE DATABASE medical_center;
\c medical_center

-- A visit is the encounter between exactly one doctor and one patient.
-- A diagnosis is recorded per visit, allowing the same disease to be diagnosed
-- during different visits without duplicating disease data.

CREATE TABLE doctors (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  specialty TEXT NOT NULL
);

CREATE TABLE patients (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE NOT NULL
);

CREATE TABLE visits (
  id SERIAL PRIMARY KEY,
  doctor_id INTEGER NOT NULL REFERENCES doctors(id),
  patient_id INTEGER NOT NULL REFERENCES patients(id),
  occurred_at TIMESTAMP NOT NULL,
  notes TEXT
);

CREATE TABLE diseases (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE visit_diagnoses (
  visit_id INTEGER NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  disease_id INTEGER NOT NULL REFERENCES diseases(id),
  PRIMARY KEY (visit_id, disease_id)
);
