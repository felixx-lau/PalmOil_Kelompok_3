-- ====================================================================
-- QUESTION 06: QUALITY REWORK AND SALES ALLOWANCES
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q06.sql
-- Description: Legitimate rework execution (re-grading, re-testing, refining)
--              vs. sales allowances and financial deduction impact.
-- ====================================================================

-- 1. Recorded Rework Activities & Costs
SELECT 
    activity,
    rework_flag,
    COUNT(*) AS execution_count,
    ROUND(SUM(TRY_CAST(labor_cost AS DECIMAL(18,2))), 2) AS total_labor_cost_myr,
    ROUND(SUM(TRY_CAST(material_cost AS DECIMAL(18,2))), 2) AS total_material_cost_myr,
    ROUND(SUM(TRY_CAST(equipment_cost AS DECIMAL(18,2))), 2) AS total_equipment_cost_myr,
    ROUND(SUM(TRY_CAST(overhead_cost AS DECIMAL(18,2))), 2) AS total_overhead_cost_myr,
    ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS total_rework_cost_myr,
    ROUND(AVG(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS avg_cost_per_execution_myr
FROM clean_events
WHERE rework_flag = true OR activity ILIKE '%rework%'
GROUP BY activity, rework_flag
ORDER BY total_rework_cost_myr DESC;

-- 2. Negative Customer Revenue Adjustments (Allowances)
SELECT 
    case_id,
    activity,
    strftime(timestamp, '%Y-%m-%d %H:%M:%S') AS allowance_timestamp,
    ROUND(TRY_CAST(revenue_allocated AS DECIMAL(18,2)), 2) AS allowance_deduction_myr,
    ROUND(TRY_CAST(activity_total_cost AS DECIMAL(18,2)), 2) AS administrative_cost_myr,
    ROUND(TRY_CAST(profit_contribution AS DECIMAL(18,2)), 2) AS net_contribution_loss_myr
FROM clean_events
WHERE activity = 'Authorized CPO Sales Allowance'
ORDER BY allowance_deduction_myr ASC;

-- 3. Summary of Overall Quality Failure & Rework Burden
SELECT 
    'Operational Rework Expenses' AS failure_type,
    COUNT(*) AS executions,
    ROUND(SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))), 2) AS financial_loss_myr
FROM clean_events
WHERE rework_flag = true OR activity ILIKE '%rework%'
UNION ALL
SELECT 
    'Commercial Sales Allowances (Penalty)',
    COUNT(*),
    ROUND(SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))), 2)
FROM clean_events
WHERE activity = 'Authorized CPO Sales Allowance';
