-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 00_import.sql
-- Purpose: Ingest raw transaction event log and authoritative master tables.
-- ====================================================================
-- 1. Import Raw Event Log as VARCHAR to preserve exact source representations
CREATE OR REPLACE TABLE raw_events AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/raw_event_log.csv', header = TRUE, all_varchar = TRUE);


-- 2. Import Master Datasets
CREATE OR REPLACE TABLE master_activities AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/activity_catalog.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_cases AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/case_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_departments AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/department_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_employees AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/employee_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_facilities AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/facility_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_ffb_grades AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/ffb_grade_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_estate_blocks AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/estate_block_master.csv', header = TRUE, all_varchar = TRUE);


CREATE OR REPLACE TABLE master_resources AS
SELECT
    *
FROM
    READ_CSV('01_DATA/raw/resource_master.csv', header = TRUE, all_varchar = TRUE);


-- 3. Initial Audit Count Verification
SELECT
    'raw_events' AS dataset,
    COUNT(*) AS row_count
FROM
    raw_events
UNION ALL
SELECT
    'master_activities',
    COUNT(*)
FROM
    master_activities
UNION ALL
SELECT
    'master_cases',
    COUNT(*)
FROM
    master_cases
UNION ALL
SELECT
    'master_departments',
    COUNT(*)
FROM
    master_departments
UNION ALL
SELECT
    'master_employees',
    COUNT(*)
FROM
    master_employees
UNION ALL
SELECT
    'master_facilities',
    COUNT(*)
FROM
    master_facilities
UNION ALL
SELECT
    'master_ffb_grades',
    COUNT(*)
FROM
    master_ffb_grades
UNION ALL
SELECT
    'master_estate_blocks',
    COUNT(*)
FROM
    master_estate_blocks
UNION ALL
SELECT
    'master_resources',
    COUNT(*)
FROM
    master_resources;
