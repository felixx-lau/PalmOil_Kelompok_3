-- Q05: standalone stage classification, identical to Q03.
CREATE OR REPLACE TEMP VIEW q03_staged_events AS
    SELECT 
        *,
        CASE 
            WHEN activity IN ('Harvest Batch Created', 'Harvest Plan Approved', 'Harvest Batch Cancelled', 'Field Team Assigned', 'Palm Ripeness Assessed', 'FFB Harvested', 'FFB Field Grading') THEN '1. Plantation / Harvesting'
            WHEN activity IN ('Harvest Collection Dispatched', 'FFB Loaded for Transport', 'Transport to Palm Oil Mill') THEN '2. Transport & Logistics'
            WHEN activity IN ('Mill Weighbridge Inbound', 'Incoming FFB Quality Inspection', 'FFB Lot Rejected', 'FFB Receipt Accepted', 'FFB Unloaded at Sterilizer Ramp') THEN '3. Weighbridge & Reception'
            WHEN activity IN ('Steam and Boiler Readiness Checked', 'FFB Sterilization Completed', 'FFB Threshing Completed', 'Fruit Digestion Completed', 'Crude Oil Pressing Completed', 'Oil Clarification Completed', 'Oil Purification Completed', 'CPO Laboratory Tested', 'CPO Quality Rework Applied', 'Kernel Separation Completed', 'Kernel Drying Completed', 'CPO Storage Tank Updated') THEN '4. Milling & Processing'
            WHEN activity IN ('CPO Transfer Authorized', 'CPO Loaded for Dispatch', 'CPO Dispatch Confirmed', 'CPO Sales Invoice Issued', 'Buyer Remittance Matched', 'Authorized CPO Sales Allowance', 'Harvest Lot Closed') THEN '5. Dispatch & Finance'
        END AS process_stage
    FROM clean_events;


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

-- 3. Total waiting per stage; same explicit classification as Q03.
SELECT process_stage, COUNT(*) AS executions, ROUND(SUM(waiting_time_minutes),2) AS total_waiting_minutes, ROUND(SUM(waiting_time_minutes)/60.0,2) AS total_waiting_hours FROM q03_staged_events GROUP BY process_stage ORDER BY process_stage;

-- 4. Daily calendar load for every facility, split at midnight.
WITH intervals AS (
    SELECT facility_id, TRY_CAST(activity_start_time AS TIMESTAMP) AS start_at,
           TRY_CAST(activity_end_time AS TIMESTAMP) AS end_at
    FROM clean_events WHERE facility_id IS NOT NULL
), daily AS (
    SELECT facility_id, day_start,
           date_diff('second', GREATEST(start_at, day_start),
                     LEAST(end_at, day_start + INTERVAL '1 day')) / 3600.0 AS processing_hours
    FROM intervals,
         LATERAL generate_series(DATE_TRUNC('day', start_at),
                                 DATE_TRUNC('day', end_at), INTERVAL '1 day') AS d(day_start)
    WHERE end_at > day_start AND start_at < day_start + INTERVAL '1 day'
)
SELECT facility_id, CAST(day_start AS DATE) AS processing_date,
       ROUND(SUM(processing_hours), 4) AS processing_hours,
       ROUND(SUM(processing_hours) / 24.0 * 100, 2) AS calendar_load_pct
FROM daily GROUP BY facility_id, day_start ORDER BY processing_date, facility_id;
