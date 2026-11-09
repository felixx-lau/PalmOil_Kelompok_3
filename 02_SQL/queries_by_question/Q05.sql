-- ====================================================================
-- QUESTION 05: MILLING FACILITY BOTTLENECK ANALYSIS
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q05.sql
-- Description: Identify processing vs. queue delays across mill facilities
--              (Weighbridge, Sterilization, Digestion, Pressing, Clarification).
-- ====================================================================

-- 1. Aggregated Station Bottlenecks
SELECT 
    activity,
    COUNT(*) AS total_lots_processed,
    COUNT(DISTINCT facility_id) AS assigned_facilities,
    ROUND(AVG(waiting_time_minutes), 2) AS avg_queue_wait_minutes,
    ROUND(SUM(waiting_time_minutes), 2) AS total_queue_wait_minutes,
    ROUND(AVG(activity_duration_minutes), 2) AS avg_processing_duration_minutes,
    ROUND(SUM(activity_duration_minutes), 2) AS total_processing_duration_minutes,
    ROUND(SUM(activity_duration_minutes) / 60.0, 2) AS total_processing_hours,
    ROUND(SUM(TRY_CAST(equipment_cost AS DECIMAL(18,2))), 2) AS total_equipment_cost_myr,
    ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS total_activity_cost_myr
FROM clean_events
WHERE activity IN (
    'Mill Weighbridge Inbound',
    'FFB Sterilization Completed',
    'FFB Threshing Completed',
    'Fruit Digestion Completed',
    'Crude Oil Pressing Completed',
    'Oil Clarification Completed',
    'Oil Purification Completed',
    'CPO Laboratory Tested'
)
GROUP BY activity
ORDER BY total_processing_duration_minutes DESC;

-- 2. Granular Facility Resource Constraints (Facility Capacity Utilization Proxy)
SELECT 
    activity,
    facility_id,
    COUNT(*) AS lots_handled,
    ROUND(AVG(waiting_time_minutes), 2) AS avg_waiting_min,
    ROUND(SUM(waiting_time_minutes), 2) AS total_waiting_min,
    ROUND(AVG(activity_duration_minutes), 2) AS avg_duration_min,
    ROUND(SUM(activity_duration_minutes) / 60.0, 2) AS total_facility_busy_hours,
    ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS total_cost_myr
FROM clean_events
WHERE facility_id IN ('FAC-029', 'FAC-030', 'FAC-031', 'FAC-038', 'FAC-039', 'FAC-040', 'FAC-041', 'FAC-042', 'FAC-043')
GROUP BY activity, facility_id
ORDER BY activity, lots_handled DESC;
