-- Initial data for ShelterAI database

-- Insert sample shelters
INSERT INTO shelters (name, address, phone_number, email, max_capacity, current_occupancy, has_medical_facilities, has_childcare, has_disability_access, languages_spoken, latitude, longitude, shelter_type, services_offered, created_at, updated_at) VALUES
('Centro Acogida Madrid Norte', 'Calle Alcalá 123, Madrid', '+34911234567', 'madrid.norte@shelter.org', 150, 45, true, true, true, 'Spanish,English,Arabic,French', 40.4168, -3.7038, 'long-term', 'Medical,Education,Legal Aid,Childcare', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Refugio Barcelona Costa', 'Av. Diagonal 456, Barcelona', '+34932345678', 'barcelona.costa@shelter.org', 100, 78, true, false, true, 'Spanish,English,Ukrainian,Russian', 41.3851, 2.1734, 'temporary', 'Medical,Legal Aid,Language Classes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Albergue Valencia Centro', 'Calle Colón 789, Valencia', '+34963456789', 'valencia.centro@shelter.org', 80, 32, false, true, false, 'Spanish,English,Arabic', 39.4699, -0.3763, 'emergency', 'Food,Childcare,Psychological Support', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Shelter Sevilla Sur', 'Av. de la Constitución 321, Sevilla', '+34954567890', 'sevilla.sur@shelter.org', 120, 95, true, true, true, 'Spanish,English,French,Portuguese', 37.3891, -5.9845, 'long-term', 'Medical,Education,Legal Aid,Job Training', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Centro Málaga Puerto', 'Paseo del Parque 111, Málaga', '+34952678901', 'malaga.puerto@shelter.org', 60, 18, false, false, true, 'Spanish,English,Arabic,French', 36.7213, -4.4214, 'temporary', 'Food,Medical,Legal Aid', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample users
INSERT INTO users (username, email, password, first_name, last_name, role, organization, phone_number, is_active, created_at, updated_at) VALUES
('admin', 'admin@shelterai.org', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin', 'System', 'ADMIN', 'ShelterAI', '+34911111111', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('maria.garcia', 'maria.garcia@redcross.org', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'María', 'García', 'STAFF', 'Red Cross', '+34922222222', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('juan.lopez', 'juan.lopez@unhcr.org', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Juan', 'López', 'STAFF', 'UNHCR', '+34933333333', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('ana.martin', 'ana.martin@volunteer.org', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Ana', 'Martín', 'VOLUNTEER', 'NGO Alliance', '+34944444444', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample families
INSERT INTO families (family_name, family_size, head_of_family_id, notes, created_at, updated_at) VALUES
('Al-Hassan Family', 5, NULL, 'Syrian family, arrived in March 2024', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Petrov Family', 3, NULL, 'Ukrainian family, needs medical attention', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Diop Family', 4, NULL, 'Senegalese family, children enrolled in school', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample refugees
INSERT INTO refugees (first_name, last_name, age, gender, nationality, languages_spoken, medical_conditions, has_disability, vulnerability_score, special_needs, family_id, created_at, updated_at) VALUES
-- Al-Hassan Family
('Ahmed', 'Al-Hassan', 42, 'M', 'Syrian', 'Arabic,English', 'Diabetes', false, 7.5, 'Needs regular medication', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Fatima', 'Al-Hassan', 38, 'F', 'Syrian', 'Arabic', NULL, false, 6.8, NULL, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Omar', 'Al-Hassan', 15, 'M', 'Syrian', 'Arabic,English', NULL, false, 5.2, 'School-age child', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Layla', 'Al-Hassan', 8, 'F', 'Syrian', 'Arabic', NULL, false, 6.1, 'School-age child', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Zayn', 'Al-Hassan', 3, 'M', 'Syrian', 'Arabic', NULL, false, 7.0, 'Requires childcare', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Petrov Family
('Ivan', 'Petrov', 35, 'M', 'Ukrainian', 'Ukrainian,Russian,English', 'Anxiety disorder', false, 6.5, 'Psychological support needed', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Olga', 'Petrov', 33, 'F', 'Ukrainian', 'Ukrainian,Russian', NULL, true, 8.2, 'Wheelchair user', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Mykola', 'Petrov', 7, 'M', 'Ukrainian', 'Ukrainian,Russian', NULL, false, 5.8, 'School-age child', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Diop Family
('Mamadou', 'Diop', 40, 'M', 'Senegalese', 'French,Wolof', NULL, false, 5.0, NULL, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Aissatou', 'Diop', 36, 'F', 'Senegalese', 'French,Wolof', NULL, false, 5.5, NULL, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Amadou', 'Diop', 12, 'M', 'Senegalese', 'French,Wolof', NULL, false, 4.8, 'School-age child', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Fatou', 'Diop', 9, 'F', 'Senegalese', 'French,Wolof', NULL, false, 4.9, 'School-age child', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Individual refugees (no family)
('Yusuf', 'Ibrahim', 22, 'M', 'Somali', 'Somali,English,Arabic', NULL, false, 6.0, 'Looking for employment', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Elena', 'Moroz', 28, 'F', 'Ukrainian', 'Ukrainian,Russian,English', 'Pregnant', false, 8.5, 'Requires prenatal care', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Hassan', 'Osman', 19, 'M', 'Eritrean', 'Tigrinya,Arabic', NULL, false, 5.5, 'Unaccompanied minor', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Update head_of_family_id after refugees are inserted
UPDATE families SET head_of_family_id = 1 WHERE id = 1;
UPDATE families SET head_of_family_id = 6 WHERE id = 2;
UPDATE families SET head_of_family_id = 9 WHERE id = 3;

-- Insert sample assignments
INSERT INTO assignments (refugee_id, shelter_id, assigned_at, status, priority_score, explanation, assigned_by, check_in_date, created_at, updated_at) VALUES
(1, 1, CURRENT_TIMESTAMP, 'confirmed', 7.5, 'High vulnerability due to medical needs. Shelter has medical facilities.', 'AI-System', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 1, CURRENT_TIMESTAMP, 'confirmed', 6.8, 'Family member assigned to same shelter', 'maria.garcia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 1, CURRENT_TIMESTAMP, 'confirmed', 5.2, 'Family member assigned to same shelter', 'maria.garcia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 1, CURRENT_TIMESTAMP, 'confirmed', 6.1, 'Family member assigned to same shelter', 'maria.garcia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 1, CURRENT_TIMESTAMP, 'confirmed', 7.0, 'Family member assigned to same shelter. Childcare available.', 'maria.garcia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 2, CURRENT_TIMESTAMP, 'confirmed', 8.2, 'High priority due to disability. Shelter has disability access.', 'AI-System', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(14, 4, CURRENT_TIMESTAMP, 'pending', 8.5, 'Pregnant woman requiring medical facilities', 'AI-System', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(13, 5, CURRENT_TIMESTAMP, 'confirmed', 6.0, 'Young adult, basic shelter requirements met', 'juan.lopez', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
