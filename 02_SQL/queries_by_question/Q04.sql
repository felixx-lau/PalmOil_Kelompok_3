-- ====================================================================
-- QUESTION 04: TIME-TO-MILL AND FFB QUALITY
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q04.sql
-- Description: Harvest-to-Mill elapsed lead time vs. provisional FFB grade,
--              rejection rates, and cost of rejected lots.
-- ====================================================================

-- 1. Duration from Harvest completion to Mill Inbound arrival
WITH harvest_to_mill_lots AS (
    SELECT 
        case_id,
        MAX(estate_block) AS estate_block,
        MAX(ffb_grade) AS ffb_grade,
        MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) AS harvest_completion_time,
        MIN(CASE WHEN activity = 'Mill Weighbridge Inbound' THEN TRY_CAST(activity_start_time AS TIMESTAMP) END) AS mill_arrival_time,
        BOOL_OR(activity = 'FFB Lot Rejected') AS is_rejected,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS lot_total_cost
    FROM clean_events
    GROUP BY case_id
    HAVING MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) IS NOT NULL
),
lot_intervals AS (
    SELECT 
        case_id,
        estate_block,
        ffb_grade,
        is_rejected,
        lot_total_cost,
        ROUND(date_diff('minute', harvest_completion_time, mill_arrival_time) / 60.0, 2) AS harvest_to_mill_hours
    FROM harvest_to_mill_lots
)
-- 2. Breakdown by Time Buckets
SELECT 
    CASE 
        WHEN harvest_to_mill_hours < 2.0 THEN '1. Rapid (< 2.0 hours)'
        WHEN harvest_to_mill_hours BETWEEN 2.0 AND 3.0 THEN '2. Standard (2.0 - 3.0 hours)'
        WHEN harvest_to_mill_hours BETWEEN 3.0 AND 4.0 THEN '3. Moderate Delay (3.0 - 4.0 hours)'
        ELSE '4. Severe Delay (> 4.0 hours)'
    END AS lead_time_bucket,
    COUNT(*) AS lots_arrived,
    SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) AS lots_rejected,
    ROUND(SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS rejection_rate_pct,
    ROUND(AVG(harvest_to_mill_hours), 2) AS avg_lead_time_hours,
    ROUND(SUM(CASE WHEN is_rejected THEN lot_total_cost ELSE 0 END), 2) AS total_rejected_cost_leakage_myr
FROM lot_intervals
GROUP BY 1
ORDER BY avg_lead_time_hours;

-- 3. Breakdown by Provisional FFB Grade
WITH harvest_to_mill_lots AS (
    SELECT 
        case_id,
        MAX(ffb_grade) AS ffb_grade,
        MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) AS harvest_completion_time,
        MIN(CASE WHEN activity = 'Mill Weighbridge Inbound' THEN TRY_CAST(activity_start_time AS TIMESTAMP) END) AS mill_arrival_time,
        BOOL_OR(activity = 'FFB Lot Rejected') AS is_rejected,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS lot_total_cost
    FROM clean_events
    GROUP BY case_id
    HAVING MIN(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(activity_end_time AS TIMESTAMP) END) IS NOT NULL
)
SELECT 
    ffb_grade,
    COUNT(*) AS total_lots_received,
    SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) AS lots_rejected,
    ROUND(SUM(CASE WHEN is_rejected THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS rejection_rate_pct,
    ROUND(AVG(date_diff('minute', harvest_completion_time, mill_arrival_time) / 60.0), 2) AS avg_lead_time_hours,
    ROUND(SUM(CASE WHEN is_rejected THEN lot_total_cost ELSE 0 END), 2) AS total_rejected_cost_myr
FROM harvest_to_mill_lots
GROUP BY ffb_grade
ORDER BY ffb_grade;
