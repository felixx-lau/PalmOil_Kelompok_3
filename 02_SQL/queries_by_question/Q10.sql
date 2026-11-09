-- ====================================================================
-- QUESTION 10: ESTATE-TO-MILL BUSINESS CASE (PRESCRIPTIVE)
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q10.sql
-- Description: Prioritization ranking of process improvements, selecting top 2,
--              comparing No-Action vs. To-Be, and providing MYR & IDR summaries.
-- ====================================================================

WITH baseline_financials AS (
    SELECT 
        SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) AS as_is_revenue,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS as_is_cost,
        SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) AS as_is_contribution
    FROM clean_events
),
fx_reference AS (
    SELECT 
        reference_idr_per_1_unit AS fx_rate
    FROM read_csv('05_FINANCIAL/exchange_rate.csv', header = true, all_varchar = true)
    WHERE reference_date = '2026-10-13' AND currency = 'MYR'
),
improvement_portfolio AS (
    SELECT 
        'Priority 1: Early FFB Grading & Field Ripeness Screening (Q08)' AS initiative,
        0.00 AS avoidable_cost_savings,
        162824.89 AS incremental_revenue,
        24673.46 AS marginal_processing_cost,
        20000.00 AS capex_implementation,
        5000.00 AS opex_maintenance,
        113151.43 AS net_financial_benefit_myr,
        1 AS priority_rank
    
    UNION ALL
    
    SELECT 
        'Priority 2: CPO Quality Retesting & Sales Allowance Mitigation (Q06)',
        8729.28 AS avoidable_cost_savings,    -- 40% rework reduction
        10474.54 AS incremental_revenue,      -- 50% allowance deduction avoidance
        0.00 AS marginal_processing_cost,
        8000.00 AS capex_implementation,      -- Storage temperature & moisture sensors
        1500.00 AS opex_maintenance,
        9703.82 AS net_financial_benefit_myr,
        2 AS priority_rank
)
SELECT 
    p.priority_rank,
    p.initiative,
    ROUND(p.avoidable_cost_savings, 2) AS avoidable_savings_myr,
    ROUND(p.incremental_revenue, 2) AS incremental_revenue_myr,
    ROUND(p.capex_implementation, 2) AS implementation_cost_myr,
    ROUND(p.opex_maintenance + p.marginal_processing_cost, 2) AS operating_cost_myr,
    ROUND(p.net_financial_benefit_myr, 2) AS net_benefit_myr,
    ROUND(p.net_financial_benefit_myr * TRY_CAST(fx.fx_rate AS DECIMAL(20,6)), 2) AS net_benefit_idr
FROM improvement_portfolio p
CROSS JOIN fx_reference fx
ORDER BY p.priority_rank;

-- Overall To-Be Business Case Summary
WITH baseline AS (
    SELECT 
        SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) AS as_is_rev,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS as_is_cost,
        SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) AS as_is_contrib
    FROM clean_events
),
portfolio AS (
    SELECT 
        173299.43 AS portfolio_revenue_gain,
        54173.46 AS portfolio_costs,
        122855.25 AS portfolio_net_benefit
),
fx AS (
    SELECT TRY_CAST(reference_idr_per_1_unit AS DECIMAL(20,6)) AS rate 
    FROM read_csv('05_FINANCIAL/exchange_rate.csv', header = true, all_varchar = true)
    WHERE reference_date = '2026-10-13' AND currency = 'MYR'
)
SELECT 
    'As-Is Baseline' AS business_state,
    ROUND(b.as_is_rev, 2) AS revenue_myr,
    ROUND(b.as_is_rev * fx.rate, 2) AS revenue_idr,
    ROUND(b.as_is_cost, 2) AS cost_myr,
    ROUND(b.as_is_cost * fx.rate, 2) AS cost_idr,
    ROUND(b.as_is_contrib, 2) AS contribution_myr,
    ROUND(b.as_is_contrib * fx.rate, 2) AS contribution_idr
FROM baseline b CROSS JOIN fx

UNION ALL

SELECT 
    'No-Action Scenario (Status Quo Persistence)',
    ROUND(b.as_is_rev, 2),
    ROUND(b.as_is_rev * fx.rate, 2),
    ROUND(b.as_is_cost, 2),
    ROUND(b.as_is_cost * fx.rate, 2),
    ROUND(b.as_is_contrib, 2),
    ROUND(b.as_is_contrib * fx.rate, 2)
FROM baseline b CROSS JOIN fx

UNION ALL

SELECT 
    'To-Be Recommended Scenario (P1 + P2 Implemented)',
    ROUND(b.as_is_rev + p.portfolio_revenue_gain, 2),
    ROUND((b.as_is_rev + p.portfolio_revenue_gain) * fx.rate, 2),
    ROUND(b.as_is_cost + p.portfolio_costs, 2),
    ROUND((b.as_is_cost + p.portfolio_costs) * fx.rate, 2),
    ROUND(b.as_is_contrib + p.portfolio_net_benefit, 2),
    ROUND((b.as_is_contrib + p.portfolio_net_benefit) * fx.rate, 2)
FROM baseline b CROSS JOIN portfolio p CROSS JOIN fx;
