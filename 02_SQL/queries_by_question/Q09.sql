-- ====================================================================
-- QUESTION 09: MILLING CAPACITY INVESTMENT (PRESCRIPTIVE)
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q09.sql
-- Description: Model a 15% increase in bottleneck facility (Sterilization) capacity.
--              Evaluates Fixed Demand vs. Expanded Demand scenarios.
-- ====================================================================

-- 1. Baseline Sterilization Metrics
WITH sterilization_baseline AS (
    SELECT 
        COUNT(*) AS total_lots_sterilized,
        ROUND(AVG(waiting_time_minutes), 2) AS avg_wait_min,
        ROUND(SUM(waiting_time_minutes), 2) AS total_wait_min,
        ROUND(AVG(activity_duration_minutes), 2) AS avg_duration_min,
        ROUND(SUM(activity_duration_minutes), 2) AS total_duration_min,
        ROUND(SUM(TRY_CAST(equipment_cost AS DECIMAL(18,2))), 2) AS total_equipment_cost_myr,
        ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS total_sterilization_cost_myr
    FROM clean_events
    WHERE activity = 'FFB Sterilization Completed'
),
investment_parameters AS (
    SELECT 
        0.15 AS capacity_increase_rate,
        110000.00 AS capex_sterilizer_upgrade, -- Capital investment
        15000.00 AS opex_steam_and_maintenance -- Additional operating expense
)
-- 2. Scenario Comparison: Fixed Demand vs. Growth Demand
SELECT 
    'Fixed Demand Scenario (189 Processed Lots)' AS demand_scenario,
    b.total_lots_sterilized,
    ROUND(b.avg_duration_min * (1 - s.capacity_increase_rate / (1 + s.capacity_increase_rate)), 2) AS to_be_duration_min,
    0.00 AS incremental_revenue_myr,
    0.00 AS incremental_cpo_sales_idr,
    s.capex_sterilizer_upgrade AS implementation_cost_myr,
    s.opex_steam_and_maintenance AS additional_operating_cost_myr,
    -(s.capex_sterilizer_upgrade + s.opex_steam_and_maintenance) AS net_financial_benefit_myr,
    ROUND(-(s.capex_sterilizer_upgrade + s.opex_steam_and_maintenance) * 4384.87, 2) AS net_financial_benefit_idr,
    'UNFEASIBLE: Under fixed demand, idle capacity increases costs without new revenue' AS investment_verdict
FROM sterilization_baseline b
CROSS JOIN investment_parameters s

UNION ALL

SELECT 
    'Growth Demand Scenario (+15% Harvest Expansion)',
    ROUND(b.total_lots_sterilized * (1 + s.capacity_increase_rate), 0),
    ROUND(b.avg_duration_min * (1 - s.capacity_increase_rate / (1 + s.capacity_increase_rate)), 2),
    ROUND((b.total_lots_sterilized * s.capacity_increase_rate) * (37431.01 - 29115.10), 2) AS incremental_revenue_myr,
    ROUND((b.total_lots_sterilized * s.capacity_increase_rate) * (37431.01 - 29115.10) * 4384.87, 2),
    s.capex_sterilizer_upgrade,
    s.opex_steam_and_maintenance,
    ROUND(((b.total_lots_sterilized * s.capacity_increase_rate) * (37431.01 - 29115.10)) - (s.capex_sterilizer_upgrade + s.opex_steam_and_maintenance), 2),
    ROUND((((b.total_lots_sterilized * s.capacity_increase_rate) * (37431.01 - 29115.10)) - (s.capex_sterilizer_upgrade + s.opex_steam_and_maintenance)) * 4384.87, 2),
    'FEASIBLE: Positive ROI only if plantation acreage and crop intake expand concurrently'
FROM sterilization_baseline b
CROSS JOIN investment_parameters s;
