-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 01_profiling.sql
-- Purpose: Thorough data profiling of raw_event_log against master data.
-- ====================================================================

-- 1. Overview of Identifiers & Volume
SELECT 
    COUNT(*) AS total_raw_rows,
    COUNT(DISTINCT raw_row_id) AS distinct_raw_rows,
    COUNT(DISTINCT event_id) AS raw_distinct_event_id,
    COUNT(DISTINCT UPPER(TRIM(event_id))) AS normalized_distinct_event_id,
    COUNT(*) - COUNT(DISTINCT UPPER(TRIM(event_id))) AS duplicate_event_rows,
    COUNT(DISTINCT case_id) AS raw_distinct_case_id,
    COUNT(DISTINCT TRIM(case_id)) AS trimmed_distinct_case_id
FROM raw_events;

-- 2. Detect Case ID Formatting Anomalies
SELECT 
    case_id AS raw_case_id,
    TRIM(case_id) AS cleaned_case_id,
    COUNT(*) AS occurrences
FROM raw_events
WHERE case_id != TRIM(case_id)
GROUP BY 1, 2;

-- 3. Detect Duplicate Event IDs (Repeated extraction records)
SELECT 
    UPPER(TRIM(event_id)) AS normalized_event_id,
    COUNT(*) AS occurrences
FROM raw_events
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 10;

-- 4. Activity Name Formatting and Casing Variations
SELECT 
    r.activity AS raw_activity,
    COUNT(*) AS event_count,
    m.activity AS catalog_activity
FROM raw_events r
LEFT JOIN master_activities m 
    ON LOWER(TRIM(r.activity)) = LOWER(TRIM(m.activity))
GROUP BY 1, 3
ORDER BY event_count DESC;

-- 5. Foreign Key Integrity Checks against Master Tables
-- 5a. Department checks
SELECT 
    r.department_id,
    r.department,
    COUNT(*) AS row_count
FROM raw_events r
LEFT JOIN master_departments d 
    ON UPPER(TRIM(r.department_id)) = UPPER(TRIM(d.department_id))
WHERE d.department_id IS NULL OR r.department != d.department
GROUP BY 1, 2;

-- 5b. Unmatched Employee, Facility, or Resource IDs
SELECT 
    COUNT(*) FILTER (WHERE r.employee_id IS NOT NULL AND TRIM(r.employee_id) != '' AND e.employee_id IS NULL) AS unmatched_employees,
    COUNT(*) FILTER (WHERE r.facility_id IS NOT NULL AND TRIM(r.facility_id) != '' AND f.facility_id IS NULL) AS unmatched_facilities,
    COUNT(*) FILTER (WHERE r.resource_id IS NOT NULL AND TRIM(r.resource_id) != '' AND res.resource_id IS NULL) AS unmatched_resources
FROM raw_events r
LEFT JOIN master_employees e ON UPPER(TRIM(r.employee_id)) = UPPER(TRIM(e.employee_id))
LEFT JOIN master_facilities f ON UPPER(TRIM(r.facility_id)) = UPPER(TRIM(f.facility_id))
LEFT JOIN master_resources res ON UPPER(TRIM(r.resource_id)) = UPPER(TRIM(res.resource_id));

-- 6. Timestamp Anomalies & Corrupted Strings
SELECT 
    raw_row_id,
    event_id,
    case_id,
    activity,
    activity_start_time,
    activity_end_time,
    timestamp
FROM raw_events
WHERE activity_start_time = 'not-a-time'
   OR activity_end_time = 'not-a-time'
   OR timestamp = 'not-a-time';

-- 7. Detection of 17 Swapped Start/End Timestamps
WITH parsed AS (
    SELECT 
        raw_row_id,
        activity,
        COALESCE(
            TRY_STRPTIME(activity_start_time, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%d/%m/%Y %H:%M')
        ) AS start_ts,
        COALESCE(
            TRY_STRPTIME(activity_end_time, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%d/%m/%Y %H:%M')
        ) AS end_ts,
        TRY_CAST(activity_duration_minutes AS DECIMAL(18,2)) AS recorded_duration
    FROM raw_events
    WHERE activity_start_time != 'not-a-time'
)
SELECT 
    raw_row_id,
    activity,
    start_ts,
    end_ts,
    recorded_duration,
    date_diff('minute', end_ts, start_ts) AS diff_start_minus_end
FROM parsed
WHERE start_ts > end_ts;

-- 8. Currency Prefix and String Format Anomalies in Financial Columns
SELECT 
    COUNT(*) FILTER (WHERE labor_cost LIKE '%RM%' OR labor_cost LIKE '%MYR%') AS labor_cost_prefixes,
    COUNT(*) FILTER (WHERE material_cost LIKE '%RM%' OR material_cost LIKE '%MYR%') AS material_cost_prefixes,
    COUNT(*) FILTER (WHERE material_cost IS NULL OR TRIM(material_cost) = '') AS material_cost_nulls,
    COUNT(*) FILTER (WHERE equipment_cost LIKE '%RM%' OR equipment_cost LIKE '%MYR%') AS equipment_cost_prefixes,
    COUNT(*) FILTER (WHERE overhead_cost LIKE '%RM%' OR overhead_cost LIKE '%MYR%') AS overhead_cost_prefixes,
    COUNT(*) FILTER (WHERE activity_total_cost LIKE '%RM%' OR activity_total_cost LIKE '%MYR%') AS total_cost_prefixes,
    COUNT(*) FILTER (WHERE revenue_allocated LIKE '%RM%' OR revenue_allocated LIKE '%MYR%') AS revenue_prefixes
FROM raw_events;
