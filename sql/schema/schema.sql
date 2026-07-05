
-- =========================
-- DROP (DEV ONLY - for eacy rebuilds)
-- =========================

CREATE SCHEMA IF NOT EXISTS warehouse;

DROP TABLE IF EXISTS warehouse.fact_medication_administration CASCADE;
DROP TABLE IF EXISTS warehouse.fact_medication_dispense CASCADE;
DROP TABLE IF EXISTS warehouse.fact_medication_verification CASCADE;
DROP TABLE IF EXISTS warehouse.fact_medication_orders CASCADE;

DROP TABLE IF EXISTS warehouse.dim_patient CASCADE;
DROP TABLE IF EXISTS warehouse.dim_provider CASCADE;
DROP TABLE IF EXISTS warehouse.dim_department CASCADE;
DROP TABLE IF EXISTS warehouse.dim_medication CASCADE;

-- =========================
-- DIM TABLES
-- =========================

CREATE TABLE warehouse.dim_patient (
    pat_id INTEGER PRIMARY KEY,
    pat_mrn_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE,
    sex VARCHAR(20),
    city VARCHAR(50),
    state CHAR(2)
);

CREATE TABLE warehouse.dim_provider (
    provider_id INTEGER PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

CREATE TABLE warehouse.dim_department (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    facility_id INTEGER,
    facility_name VARCHAR(100),
    unit_abbreviation VARCHAR(20)
);

CREATE TABLE warehouse.dim_medication (
    medication_id INTEGER PRIMARY KEY,
    generic_name VARCHAR(100) NOT NULL,
    therapeutic_class VARCHAR(100),
    formulary_status VARCHAR(20),
    controlled_substance BOOLEAN,
    control_level VARCHAR(10)
);


-- =========================
-- FACT TABLES
-- =========================

CREATE TABLE warehouse.fact_medication_orders (
    order_id INTEGER PRIMARY KEY,

    patient_id INTEGER NOT NULL,
    provider_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    medication_id INTEGER NOT NULL,

    order_date TIMESTAMP,
    ordered_dose NUMERIC(10,2),
    ordered_route VARCHAR(30),
    priority VARCHAR(20),
    status VARCHAR(30),

    CONSTRAINT fk_patient
        FOREIGN KEY (patient_id)
        REFERENCES warehouse.dim_patient(pat_id),

    CONSTRAINT fk_provider
        FOREIGN KEY (provider_id)
        REFERENCES warehouse.dim_provider(provider_id),

    CONSTRAINT fk_department
        FOREIGN KEY (department_id)
        REFERENCES warehouse.dim_department(department_id),

    CONSTRAINT fk_medication
        FOREIGN KEY (medication_id)
        REFERENCES warehouse.dim_medication(medication_id)
);

CREATE TABLE warehouse.fact_medication_verification (

    order_id INTEGER PRIMARY KEY,

    verifying_provider_id INTEGER,
    verify_time TIMESTAMP,
    queue_time INTEGER,
    stat_order BOOLEAN,

    CONSTRAINT fk_order_verify
        FOREIGN KEY (order_id)
        REFERENCES warehouse.fact_medication_orders(order_id),

    CONSTRAINT fk_verify_provider
        FOREIGN KEY (verifying_provider_id)
        REFERENCES warehouse.dim_provider(provider_id)
);

CREATE TABLE warehouse.fact_medication_dispense (

    order_id INTEGER PRIMARY KEY,

    dispense_time TIMESTAMP,
    dispense_quantity NUMERIC(10,2),
    dispense_quantity_unit VARCHAR(20),
    return_status BOOLEAN,

    CONSTRAINT fk_order_dispense
        FOREIGN KEY (order_id)
        REFERENCES warehouse.fact_medication_orders(order_id)
);
