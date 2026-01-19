CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  username VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  role VARCHAR(50),
  phone_number VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS refugee (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  age INT,
  gender VARCHAR(10),
  nationality VARCHAR(100),
  family_size INT DEFAULT 1,
  has_children BOOLEAN DEFAULT FALSE,
  children_count INT DEFAULT 0,
  medical_conditions TEXT,
  requires_medical_facilities BOOLEAN DEFAULT FALSE,
  languages_spoken TEXT,
  vulnerability_score FLOAT,
  special_needs TEXT,
  has_disability BOOLEAN DEFAULT FALSE,
  assigned_shelter_id INT,
  status VARCHAR(50) DEFAULT 'new',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS shelter (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  address VARCHAR(255),
  city VARCHAR(100),
  max_capacity INT,
  available_space INT,
  has_medical_facilities BOOLEAN DEFAULT FALSE,
  has_childcare BOOLEAN DEFAULT FALSE,
  phone VARCHAR(20),
  email VARCHAR(255),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO refugee (first_name, last_name, age, gender, nationality, family_size, has_children, vulnerability_score) VALUES
('Juan', 'García', 35, 'M', 'Colombia', 1, FALSE, 5.0),
('María', 'López', 28, 'F', 'Venezuela', 2, TRUE, 7.5),
('Carlos', 'Martínez', 42, 'M', 'Siria', 3, TRUE, 8.0);

INSERT INTO shelter (name, address, city, max_capacity, available_space, has_medical_facilities, has_childcare) VALUES
('Refugio Central', 'Calle Principal 123', 'Madrid', 50, 20, TRUE, FALSE),
('Hogar Seguro', 'Avenida Paz 456', 'Madrid', 30, 15, TRUE, TRUE),
('Casa Abierta', 'Paseo Verde 789', 'Madrid', 25, 10, FALSE, FALSE);
