-- ====================================================================
-- QUESTION 07: FFB TRANSPORT SCHEDULING (PRESCRIPTIVE)
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q07.sql
-- Description: Scenario modeling for a 20% reduction in transport waiting time.
--              Distinguishing idle time savings from avoidable cash cost.
-- ====================================================================

-- 1. Transportation Stage Waiting Time Baseline
WITH transport_baseline AS (
    SELECT 
        activity,
        COUNT(*) AS execution_count,
        ROUND(SUM(waiting_time_minutes), 2) AS baseline_waiting_minutes,
        ROUND(SUM(waiting_time_minutes) / 60.0, 2) AS baseline_waiting_hours,
        ROUND(AVG(waiting_time_minutes), 2) AS avg_waiting_minutes_per_event,
        ROUND(SUM(TRY_CAST(equipment_cost AS DECIMAL(18,2))), 2) AS baseline_truck_cost,
        ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS baseline_total_cost
    FROM clean_events
    WHERE activity IN ('Harvest Collection Dispatched', 'FFB Loaded for Transport', 'Transport to Palm Oil Mill')
    GROUP BY activity
)
SELECT 
    *,
    ROUND(baseline_waiting_minutes * 0.20, 2) AS minutes_saved_at_20pct,
    ROUND(baseline_waiting_hours * 0.20, 2) AS hours_saved_at_20pct
FROM transport_baseline;


-- Requires 06_scenario_model.sql in the same connection.
SELECT * FROM scenario_comparison WHERE scenario_id LIKE 'Q07_SCHED%' ORDER BY scenario_id;
