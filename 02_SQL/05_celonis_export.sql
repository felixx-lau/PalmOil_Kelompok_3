-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 05_celonis_export.sql
-- Purpose: Export fully verified event log for Celonis Process Mining ingestion.
-- ====================================================================

-- Export Cleaned Event Log with explicit sorting for process reconstruction
COPY (
    SELECT 
        event_id,
        case_id,
        activity,
        strftime(activity_start_time, '%Y-%m-%d %H:%M:%S') AS activity_start_time,
        strftime(activity_end_time, '%Y-%m-%d %H:%M:%S') AS activity_end_time,
        strftime(timestamp, '%Y-%m-%d %H:%M:%S') AS timestamp,
        strftime(activity_ready_time, '%Y-%m-%d %H:%M:%S') AS activity_ready_time,
        department_id,
        department,
        employee_id,
        employee_role,
        resource_id,
        resource_type,
        organizational_unit,
        facility_id,
        activity_duration_minutes,
        waiting_time_minutes,
        case_elapsed_time_minutes,
        activity_sla_minutes,
        sla_violation,
        rework_flag,
        activity_status,
        labor_cost,
        material_cost,
        equipment_cost,
        overhead_cost,
        activity_total_cost,
        revenue_allocated,
        profit_contribution,
        currency,
        case_type,
        case_priority,
        case_complexity,
        location,
        harvest_batch_id,
        processing_lot_id,
        estate_block,
        ffb_grade,
        exception_flag,
        exception_type
    FROM clean_events 
    ORDER BY case_id, timestamp, event_id
)
TO '01_DATA/cleaned/celonis_event_log_clean.csv' 
(HEADER TRUE, DELIMITER ',');

-- Export Success Verification
SELECT 'Export completed successfully. Records: ' || COUNT(*) AS status_message
FROM read_csv('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);
