-- ====================================================================
-- QUESTION 03: PLANTATION-TO-MILL PERFORMANCE
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q03.sql
-- Description: Stage-level performance comparing waiting time, processing time,
--              SLA compliance, and total stage cost across operational stages.
-- ====================================================================

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

-- 1. Aggregate event waiting and processing; totals are not case throughput.
SELECT 
    process_stage,
    COUNT(*) AS total_executions,
    ROUND(AVG(waiting_time_minutes), 2) AS avg_waiting_minutes,
    ROUND(SUM(waiting_time_minutes), 2) AS total_waiting_minutes,
    ROUND(SUM(waiting_time_minutes) / 60.0, 2) AS total_waiting_hours,
    ROUND(AVG(activity_duration_minutes), 2) AS avg_duration_minutes,
    ROUND(SUM(activity_duration_minutes), 2) AS total_duration_minutes,
    ROUND(SUM(activity_duration_minutes) / 60.0, 2) AS total_processing_hours,
    ROUND(AVG(activity_sla_minutes), 2) AS avg_target_sla_minutes,
    SUM(CASE WHEN sla_violation THEN 1 ELSE 0 END) AS total_sla_violations,
    ROUND(SUM(CASE WHEN sla_violation THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS sla_violation_rate_pct,
    ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS total_stage_cost_myr
FROM q03_staged_events
GROUP BY process_stage
ORDER BY process_stage;


-- 2. Include all months, so zero-waiting months remain visible.
-- Month attribution uses the event completion timestamp.
SELECT DATE_TRUNC('month', TRY_CAST(timestamp AS TIMESTAMP)) AS event_month,
       COUNT(*) FILTER (WHERE waiting_time_minutes > 0) AS waiting_events,
       ROUND(SUM(waiting_time_minutes) / 60.0, 2) AS total_waiting_hours,
       SUM(CASE WHEN sla_violation THEN 1 ELSE 0 END) AS sla_violations
FROM clean_events GROUP BY 1 ORDER BY 1;

-- 3. Daily shipments use transport START, not collection dispatch or completion.
SELECT CAST(activity_start_time AS DATE) AS transport_date,
       COUNT(*) AS shipments, COUNT(DISTINCT case_id) AS cases
FROM clean_events WHERE activity = 'Transport to Palm Oil Mill'
GROUP BY 1 ORDER BY 1;

-- 4. Daily sterilizer load splits activity intervals at midnight.
-- Denominator: 24 calendar hours per facility per day; not staffed availability.
-- Sum of logged processing intervals; overlapping records can double-count.
WITH intervals AS (
    SELECT facility_id, TRY_CAST(activity_start_time AS TIMESTAMP) AS start_at,
           TRY_CAST(activity_end_time AS TIMESTAMP) AS end_at
    FROM clean_events WHERE activity = 'FFB Sterilization Completed'
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
