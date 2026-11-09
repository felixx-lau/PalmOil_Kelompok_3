-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 03_validation.sql
-- Purpose: Rigorous data quality and financial validation post-cleaning.
-- ====================================================================

-- 1. Identifier Uniqueness and Completeness
SELECT 
    COUNT(*) AS total_clean_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) FILTER (WHERE event_id IS NULL OR TRIM(event_id) = '') AS missing_event_ids,
    COUNT(*) FILTER (WHERE c.case_id IS NULL OR TRIM(c.case_id) = '') AS missing_case_ids,
    COUNT(DISTINCT c.case_id) AS total_cases,
    COUNT(DISTINCT m.case_id) AS master_cases_matched
FROM clean_events c
LEFT JOIN master_cases m ON c.case_id = m.case_id;

-- 2. Timestamp Chronological Sanity
SELECT 
    COUNT(*) FILTER (WHERE activity_start_time IS NULL) AS null_start_times,
    COUNT(*) FILTER (WHERE activity_end_time IS NULL) AS null_end_times,
    COUNT(*) FILTER (WHERE timestamp IS NULL) AS null_timestamps,
    COUNT(*) FILTER (WHERE activity_start_time > activity_end_time) AS inverted_durations,
    COUNT(*) FILTER (WHERE activity_duration_minutes <= 0) AS non_positive_durations,
    COUNT(*) FILTER (WHERE waiting_time_minutes < 0) AS negative_waiting_times
FROM clean_events;

-- 3. Financial Identity Integrity
SELECT 
    COUNT(*) FILTER (
        WHERE ABS((labor_cost + material_cost + equipment_cost + overhead_cost) - activity_total_cost) > 0.01
    ) AS cost_component_mismatches,
    COUNT(*) FILTER (
        WHERE ABS(profit_contribution - (revenue_allocated - activity_total_cost)) > 0.01
    ) AS contribution_identity_mismatches
FROM clean_events;

-- 4. Revenue Recognition Integrity
-- Revenue must only be positive on CPO Dispatch Confirmed, and negative on Authorized CPO Sales Allowance
SELECT 
    activity,
    COUNT(*) AS event_count,
    ROUND(SUM(revenue_allocated), 2) AS total_revenue_allocated,
    COUNT(*) FILTER (WHERE revenue_allocated > 0 AND activity != 'CPO Dispatch Confirmed') AS unauthorized_positive_revenue,
    COUNT(*) FILTER (WHERE revenue_allocated < 0 AND activity != 'Authorized CPO Sales Allowance') AS unauthorized_negative_revenue
FROM clean_events
GROUP BY activity
HAVING SUM(revenue_allocated) != 0;

-- 5. Referential Integrity Summary
SELECT 
    COUNT(*) FILTER (WHERE ac.activity IS NULL) AS unmapped_activities,
    COUNT(*) FILTER (WHERE dm.department_id IS NULL) AS unmapped_departments,
    COUNT(*) FILTER (WHERE c.employee_id IS NOT NULL AND em.employee_id IS NULL) AS unmapped_employees,
    COUNT(*) FILTER (WHERE c.resource_id IS NOT NULL AND rm.resource_id IS NULL) AS unmapped_resources
FROM clean_events c
LEFT JOIN master_activities ac ON c.activity = ac.activity
LEFT JOIN master_departments dm ON c.department_id = dm.department_id
LEFT JOIN master_employees em ON c.employee_id = em.employee_id
LEFT JOIN master_resources rm ON c.resource_id = rm.resource_id;
