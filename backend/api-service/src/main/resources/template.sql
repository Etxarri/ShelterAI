BEGIN;

-- Borra en orden para evitar conflictos por FKs
DROP TABLE IF EXISTS public.assignments CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.refugees CASCADE;
DROP TABLE IF EXISTS public.families CASCADE;
DROP TABLE IF EXISTS public.shelters CASCADE;

-- ===== families =====
CREATE TABLE public.families (
  id BIGSERIAL PRIMARY KEY,              -- int8
  created_at TIMESTAMP,
  family_name VARCHAR,
  family_size INT4,
  head_of_family_id BIGINT,              -- int8 (FK se añade luego por circularidad)
  notes VARCHAR,
  updated_at TIMESTAMP
);

-- ===== refugees =====
CREATE TABLE public.refugees (
  id BIGSERIAL PRIMARY KEY,              -- int8
  age INT4,
  created_at TIMESTAMP,
  first_name VARCHAR,
  gender VARCHAR,
  has_disability BOOLEAN,
  languages_spoken VARCHAR,
  last_name VARCHAR,
  medical_conditions VARCHAR,
  nationality VARCHAR,
  special_needs VARCHAR,
  updated_at TIMESTAMP,
  vulnerability_score FLOAT8,
  family_id BIGINT                        -- int8
);

-- FK: refugees.family_id -> families.id
ALTER TABLE public.refugees
  ADD CONSTRAINT fk_refugees_family
  FOREIGN KEY (family_id) REFERENCES public.families(id)
  ON DELETE SET NULL;

-- FK: families.head_of_family_id -> refugees.id (se añade después para romper el ciclo)
ALTER TABLE public.families
  ADD CONSTRAINT fk_families_head
  FOREIGN KEY (head_of_family_id) REFERENCES public.refugees(id)
  ON DELETE SET NULL;

-- ===== shelters =====
CREATE TABLE public.shelters (
  id BIGSERIAL PRIMARY KEY,              -- int8
  address VARCHAR,
  created_at TIMESTAMP,
  current_occupancy INT4,
  email VARCHAR,
  has_childcare BOOLEAN,
  has_disability_access BOOLEAN,
  has_medical_facilities BOOLEAN,
  languages_spoken VARCHAR,
  latitude FLOAT8,
  longitude FLOAT8,
  max_capacity INT4,
  name VARCHAR,
  phone_number VARCHAR,
  services_offered VARCHAR,
  shelter_type VARCHAR,
  updated_at TIMESTAMP
);

-- ===== assignments =====
CREATE TABLE public.assignments (
  id BIGSERIAL PRIMARY KEY,              -- int8
  assigned_at TIMESTAMP,
  assigned_by VARCHAR,
  check_in_date TIMESTAMP,
  check_out_date TIMESTAMP,
  created_at TIMESTAMP,
  explanation VARCHAR,
  priority_score FLOAT8,
  status VARCHAR,
  updated_at TIMESTAMP,
  refugee_id BIGINT,
  shelter_id BIGINT,

  CONSTRAINT fk_assignments_refugee
    FOREIGN KEY (refugee_id) REFERENCES public.refugees(id)
    ON DELETE SET NULL,

  CONSTRAINT fk_assignments_shelter
    FOREIGN KEY (shelter_id) REFERENCES public.shelters(id)
    ON DELETE SET NULL
);

-- ===== users =====
CREATE TABLE public.users (
  id SERIAL PRIMARY KEY,                 -- int4
  email VARCHAR,
  password VARCHAR,
  full_name VARCHAR,
  role VARCHAR,
  created_at TIMESTAMP
);

-- Índices útiles para joins (como en el diagrama hay muchas relaciones)
CREATE INDEX idx_refugees_family_id ON public.refugees(family_id);
CREATE INDEX idx_families_head_of_family_id ON public.families(head_of_family_id);
CREATE INDEX idx_assignments_refugee_id ON public.assignments(refugee_id);
CREATE INDEX idx_assignments_shelter_id ON public.assignments(shelter_id);

COMMIT;


INSERT INTO shelters (name, address, max_capacity, current_occupancy, shelter_type, has_medical_facilities, has_disability_access, has_childcare,created_at) VALUES ('Centro de Acogida Esperanza', 'Av. Principal 123, Madrid', 50, 12, 'Emergencia', true, true, false,NOW());


INSERT INTO shelters (name, max_capacity, current_occupancy, has_medical_facilities, has_childcare, has_disability_access, languages_spoken) VALUES ('Refugio Norte', 50, 10, true, true, true, 'Spanish, English'), ('Refugio Sur', 30, 25, false, true, false, 'Spanish'), ('Refugio Central', 100, 45, true, true, true, 'Spanish, English, French');