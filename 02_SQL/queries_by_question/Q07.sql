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
        COUNT(*) AS trip_count,
        ROUND(SUM(waiting_time_minutes), 2) AS baseline_waiting_minutes,
        ROUND(SUM(waiting_time_minutes) / 60.0, 2) AS baseline_waiting_hours,
        ROUND(AVG(waiting_time_minutes), 2) AS avg_waiting_minutes_per_trip,
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

-- 2. What-If Financial Valuation of Transport Scheduling
WITH baseline_transport AS (
    SELECT 
        SUM(waiting_time_minutes) / 60.0 AS total_waiting_hours,
        SUM(TRY_CAST(equipment_cost AS DECIMAL(18,2))) AS total_truck_equipment_cost,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS total_transport_cost
    FROM clean_events
    WHERE activity IN ('Harvest Collection Dispatched', 'FFB Loaded for Transport', 'Transport to Palm Oil Mill')
),
scheduling_assumptions AS (
    SELECT 
        0.20 AS waiting_reduction_rate,
        0.12 AS avoidable_share_of_equipment_cost, -- only 12% avoidable idle fuel and demurrage while drivers salaried
        6000.00 AS implementation_cost,           -- mobile dispatch schedule tool setup
        1200.00 AS additional_operating_cost      -- annual maintenance & cellular data
)
SELECT 
    b.total_waiting_hours AS as_is_waiting_hours,
    ROUND(b.total_waiting_hours * (1 - a.waiting_reduction_rate), 2) AS to_be_waiting_hours,
    ROUND(b.total_waiting_hours * a.waiting_reduction_rate, 2) AS saved_waiting_hours,
    ROUND(b.total_truck_equipment_cost * a.avoidable_share_of_equipment_cost * a.waiting_reduction_rate, 2) AS avoidable_cost_savings_myr,
    a.implementation_cost AS implementation_cost_myr,
    a.additional_operating_cost AS annual_operating_cost_myr,
    ROUND(
        (b.total_truck_equipment_cost * a.avoidable_share_of_equipment_cost * a.waiting_reduction_rate)
        - a.implementation_cost - a.additional_operating_cost, 2
    ) AS net_financial_benefit_myr,
    ROUND(
        ((b.total_truck_equipment_cost * a.avoidable_share_of_equipment_cost * a.waiting_reduction_rate)
        - a.implementation_cost - a.additional_operating_cost) * 4384.87, 2
    ) AS net_financial_benefit_idr
FROM baseline_transport b 
CROSS JOIN scheduling_assumptions a;
