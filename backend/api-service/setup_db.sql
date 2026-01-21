DROP TABLE IF EXISTS refugees CASCADE;
DROP TABLE IF EXISTS shelters CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. TABLA USERS
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

-- 2. TABLA REFUGEES
CREATE TABLE IF NOT EXISTS refugees (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  email VARCHAR(255),
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

-- 3. TABLA SHELTERS
CREATE TABLE IF NOT EXISTS shelters (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  address VARCHAR(255),
  city VARCHAR(100),
  max_capacity INT,
  available_space INT,
  has_medical_facilities BOOLEAN DEFAULT FALSE,
  has_childcare BOOLEAN DEFAULT FALSE,
  has_disability_access BOOLEAN DEFAULT FALSE,
  type VARCHAR(50) DEFAULT 'general',
  phone VARCHAR(20),
  email VARCHAR(255),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar refugios
INSERT INTO shelters (name, address, city, max_capacity, available_space, has_medical_facilities, has_childcare, has_disability_access, type, status) VALUES
('Refugio Central Madrid', 'Calle Atocha 12', 'Madrid', 100, 50, FALSE, FALSE, FALSE, 'general', 'active'),
('Centro Sanitario Cruz Roja', 'Av. Reina Victoria 45', 'Madrid', 40, 10, TRUE, FALSE, TRUE, 'special_care', 'active'),
('Casa Familiar La Paz', 'Calle de los Niños 8', 'Madrid', 60, 20, TRUE, TRUE, FALSE, 'family', 'active'),
('Residencia Sin Barreras', 'Paseo de la Castellana 200', 'Madrid', 30, 5, TRUE, FALSE, TRUE, 'special_care', 'active');

-- Insertar refugiados
INSERT INTO refugees (first_name, last_name, age, gender, nationality, family_size, has_children, children_count, has_disability, medical_conditions, vulnerability_score, status) VALUES
('Carlos', 'Pérez', 25, 'Male', 'Venezuela', 1, FALSE, 0, FALSE, 'None', 2.0, 'new'),
('Fatima', 'Al-Sayed', 34, 'Female', 'Syria', 4, TRUE, 3, FALSE, 'None', 8.5, 'new'),
('Ivan', 'Popov', 68, 'Male', 'Ukraine', 1, FALSE, 0, TRUE, 'Mobility issues', 9.0, 'new'),
('Luis', 'Gomez', 40, 'Male', 'Colombia', 1, FALSE, 0, FALSE, 'Chronic Kidney Disease', 7.0, 'new');

-- Insertar usuario
INSERT INTO users (email, username, password, first_name, last_name, role) VALUES
('trabajador@test.com', 'admin', 'admin123', 'Super', 'Admin', 'admin');

SELECT 'Base de datos actualizada correctamente' AS mensaje;
