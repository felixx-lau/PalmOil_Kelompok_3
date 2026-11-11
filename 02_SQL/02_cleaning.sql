-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 02_cleaning.sql
-- Purpose: Complete data cleaning, deduplication, repairing, and normalization.
-- ====================================================================

-- 1. Create Quarantine Table for Irrecoverable Records
CREATE OR REPLACE TABLE quarantined_events AS
SELECT 
    raw_row_id,
    event_id,
    case_id,
    activity,
    activity_start_time,
    activity_end_time,
    timestamp,
    activity_ready_time,
    activity_total_cost AS source_activity_total_cost,
    revenue_allocated AS source_revenue_allocated,
    profit_contribution AS source_profit_contribution,
    'Corrupted unrecoverable timestamp (not-a-time) - excluded to prevent synthetic fabrication' AS quarantine_reason
FROM raw_events
WHERE activity_start_time = 'not-a-time'
   OR activity_end_time = 'not-a-time'
   OR timestamp = 'not-a-time';

-- 2. Build Cleaned Event Log Table
CREATE OR REPLACE TABLE clean_events AS
WITH deduplicated AS (
    SELECT 
        raw_row_id,
        UPPER(TRIM(event_id)) AS norm_event_id,
        TRIM(case_id) AS norm_case_id,
        LOWER(TRIM(r.activity)) AS raw_act_lower,
        
        -- Multi-format Timestamp Parsing (Day-first aware)
        COALESCE(
            TRY_STRPTIME(activity_start_time, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(activity_start_time, '%d/%m/%Y %H:%M'),
            TRY_STRPTIME(activity_start_time, '%Y-%m-%d %H:%M')
        ) AS parsed_start,
        
        COALESCE(
            TRY_STRPTIME(activity_end_time, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(activity_end_time, '%d/%m/%Y %H:%M'),
            TRY_STRPTIME(activity_end_time, '%Y-%m-%d %H:%M')
        ) AS parsed_end,
        
        COALESCE(
            TRY_STRPTIME(timestamp, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(timestamp, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(timestamp, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(timestamp, '%d/%m/%Y %H:%M'),
            TRY_STRPTIME(timestamp, '%Y-%m-%d %H:%M')
        ) AS parsed_ts,
        
        COALESCE(
            TRY_STRPTIME(activity_ready_time, '%Y-%m-%d %H:%M:%S'),
            TRY_STRPTIME(activity_ready_time, '%Y/%m/%d %H:%M:%S'),
            TRY_STRPTIME(activity_ready_time, '%d/%m/%Y %H:%M:%S'),
            TRY_STRPTIME(activity_ready_time, '%d/%m/%Y %H:%M'),
            TRY_STRPTIME(activity_ready_time, '%Y-%m-%d %H:%M')
        ) AS parsed_ready,

        UPPER(TRIM(r.department_id)) AS norm_department_id,
        NULLIF(UPPER(TRIM(r.employee_id)), '') AS norm_employee_id,
        NULLIF(UPPER(TRIM(r.resource_id)), '') AS norm_resource_id,
        NULLIF(UPPER(TRIM(r.facility_id)), '') AS norm_facility_id,

        TRY_CAST(activity_duration_minutes AS DECIMAL(18,2)) AS norm_duration,
        TRY_CAST(waiting_time_minutes AS DECIMAL(18,2)) AS norm_waiting,
        TRY_CAST(case_elapsed_time_minutes AS DECIMAL(18,2)) AS norm_elapsed,
        TRY_CAST(activity_sla_minutes AS INTEGER) AS norm_sla,
        LOWER(TRIM(sla_violation)) IN ('true', '1', 'yes', 'y', 't') AS norm_sla_viol,
        LOWER(TRIM(rework_flag)) IN ('true', '1', 'yes', 'y', 't') AS norm_rework,
        TRIM(activity_status) AS norm_status,

        -- Strip currency formatting (RM / MYR) and cast to numeric
        TRY_CAST(REGEXP_REPLACE(labor_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_labor_cost,
        
        -- Compute missing material_cost using total cost balance identity
        COALESCE(
            TRY_CAST(REGEXP_REPLACE(material_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)),
            TRY_CAST(REGEXP_REPLACE(activity_total_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) - (
                TRY_CAST(REGEXP_REPLACE(labor_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) +
                TRY_CAST(REGEXP_REPLACE(equipment_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) +
                TRY_CAST(REGEXP_REPLACE(overhead_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2))
            )
        ) AS norm_material_cost,
        
        TRY_CAST(REGEXP_REPLACE(equipment_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_equipment_cost,
        TRY_CAST(REGEXP_REPLACE(overhead_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_overhead_cost,
        TRY_CAST(REGEXP_REPLACE(activity_total_cost, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_total_cost,
        TRY_CAST(REGEXP_REPLACE(revenue_allocated, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_revenue,
        TRY_CAST(REGEXP_REPLACE(profit_contribution, '[^0-9.-]', '', 'g') AS DECIMAL(18,2)) AS norm_contribution,

        'MYR' AS norm_currency,
        TRIM(case_type) AS norm_case_type,
        TRIM(case_priority) AS norm_priority,
        TRIM(case_complexity) AS norm_complexity,
        TRIM(location) AS norm_location,
        TRIM(harvest_batch_id) AS norm_batch_id,
        TRIM(processing_lot_id) AS norm_lot_id,
        TRIM(estate_block) AS norm_estate_block,
        TRIM(ffb_grade) AS norm_ffb_grade,
        LOWER(TRIM(exception_flag)) IN ('true', '1', 'yes', 'y', 't') AS norm_exception_flag,
        NULLIF(TRIM(exception_type), '') AS norm_exception_type,

        -- Deduplication window: keep cleanest source record per normalized event_id
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(event_id)) 
            ORDER BY 
                CASE WHEN material_cost IS NOT NULL AND material_cost NOT LIKE '%RM%' AND material_cost NOT LIKE '%MYR%' THEN 1 ELSE 2 END,
                raw_row_id
        ) AS rn
    FROM raw_events r
    WHERE raw_row_id NOT IN (SELECT raw_row_id FROM quarantined_events)
)
SELECT 
    d.norm_event_id AS event_id,
    d.norm_case_id AS case_id,
    ac.activity AS activity,
    
    -- Inversion Repair: Swap start and end timestamps where start > end (17 records)
    CASE WHEN d.parsed_start > d.parsed_end THEN d.parsed_end ELSE d.parsed_start END AS activity_start_time,
    CASE WHEN d.parsed_start > d.parsed_end THEN d.parsed_start ELSE d.parsed_end END AS activity_end_time,
    CASE WHEN d.parsed_start > d.parsed_end THEN d.parsed_start ELSE d.parsed_ts END AS timestamp,
    -- Ready is independent evidence: preserve it even when start/end are swapped.
    d.parsed_ready AS activity_ready_time,
    
    d.norm_department_id AS department_id,
    dm.department AS department,
    d.norm_employee_id AS employee_id,
    em.employee_role AS employee_role,
    d.norm_resource_id AS resource_id,
    rm.resource_type AS resource_type,
    dm.organizational_unit AS organizational_unit,
    d.norm_facility_id AS facility_id,
    d.norm_duration AS activity_duration_minutes,
    d.norm_waiting AS waiting_time_minutes,
    d.norm_elapsed AS case_elapsed_time_minutes,
    d.norm_sla AS activity_sla_minutes,
    d.norm_sla_viol AS sla_violation,
    d.norm_rework AS rework_flag,
    d.norm_status AS activity_status,
    d.norm_labor_cost AS labor_cost,
    d.norm_material_cost AS material_cost,
    d.norm_equipment_cost AS equipment_cost,
    d.norm_overhead_cost AS overhead_cost,
    d.norm_total_cost AS activity_total_cost,
    d.norm_revenue AS revenue_allocated,
    d.norm_contribution AS profit_contribution,
    d.norm_currency AS currency,
    d.norm_case_type AS case_type,
    d.norm_priority AS case_priority,
    d.norm_complexity AS case_complexity,
    d.norm_location AS location,
    d.norm_batch_id AS harvest_batch_id,
    d.norm_lot_id AS processing_lot_id,
    d.norm_estate_block AS estate_block,
    d.norm_ffb_grade AS ffb_grade,
    d.norm_exception_flag AS exception_flag,
    d.norm_exception_type AS exception_type
FROM deduplicated d
JOIN master_activities ac ON d.raw_act_lower = LOWER(TRIM(ac.activity))
JOIN master_departments dm ON d.norm_department_id = UPPER(TRIM(dm.department_id))
LEFT JOIN master_employees em ON d.norm_employee_id = UPPER(TRIM(em.employee_id))
LEFT JOIN master_resources rm ON d.norm_resource_id = UPPER(TRIM(rm.resource_id))
WHERE d.rn = 1
ORDER BY d.norm_case_id, timestamp, d.norm_event_id;

-- 3. Post-Cleaning Verification
SELECT 
    'clean_events' AS table_name,
    COUNT(*) AS total_clean_rows,
    COUNT(DISTINCT event_id) AS distinct_event_ids,
    COUNT(DISTINCT case_id) AS distinct_cases
FROM clean_events;
