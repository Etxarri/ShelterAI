-- ShelterAI Database Schema
-- PostgreSQL

-- Drop tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS refugees CASCADE;
DROP TABLE IF EXISTS families CASCADE;
DROP TABLE IF EXISTS shelters CASCADE;

-- Table: shelters
CREATE TABLE shelters (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(500),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    max_capacity INTEGER,
    current_occupancy INTEGER,
    has_medical_facilities BOOLEAN,
    has_childcare BOOLEAN,
    has_disability_access BOOLEAN,
    languages_spoken VARCHAR(200),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    shelter_type VARCHAR(50),
    services_offered VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: families
CREATE TABLE families (
    id BIGSERIAL PRIMARY KEY,
    family_name VARCHAR(100),
    family_size INTEGER,
    head_of_family_id BIGINT,
    notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: refugees
CREATE TABLE refugees (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL,
    gender VARCHAR(10),
    nationality VARCHAR(100),
    languages_spoken VARCHAR(200),
    medical_conditions VARCHAR(500),
    has_disability BOOLEAN,
    vulnerability_score DOUBLE PRECISION,
    special_needs VARCHAR(500),
    family_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refugee_family FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE SET NULL
);

-- Table: assignments
CREATE TABLE assignments (
    id BIGSERIAL PRIMARY KEY,
    refugee_id BIGINT NOT NULL,
    shelter_id BIGINT NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    priority_score DOUBLE PRECISION,
    explanation VARCHAR(1000),
    assigned_by VARCHAR(100),
    check_in_date TIMESTAMP,
    check_out_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_assignment_refugee FOREIGN KEY (refugee_id) REFERENCES refugees(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignment_shelter FOREIGN KEY (shelter_id) REFERENCES shelters(id) ON DELETE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_refugee_family ON refugees(family_id);
CREATE INDEX idx_refugee_vulnerability ON refugees(vulnerability_score);
CREATE INDEX idx_assignment_refugee ON assignments(refugee_id);
CREATE INDEX idx_assignment_shelter ON assignments(shelter_id);
CREATE INDEX idx_assignment_status ON assignments(status);
CREATE INDEX idx_shelter_capacity ON shelters(current_occupancy, max_capacity);
