-- ====================================================================
-- QUESTION 08: FFB GRADING IMPROVEMENT (PRESCRIPTIVE)
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q08.sql
-- Description: Test 15% reduction in FFB Rejection Rate via early field inspection.
--              Models sunk crop cost vs. marginal milling cost and incremental revenue.
-- ====================================================================

-- 1. Baseline Economics of Processed vs. Rejected Lots
WITH lot_financials AS (
    SELECT 
        case_id,
        BOOL_OR(activity = 'CPO Dispatch Confirmed') AS is_dispatched,
        BOOL_OR(activity = 'FFB Lot Rejected') AS is_rejected,
        SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) AS revenue,
        SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS total_cost,
        SUM(CASE WHEN activity = 'FFB Harvested' THEN TRY_CAST(material_cost AS DECIMAL(18,2)) ELSE 0 END) AS crop_sunk_cost,
        SUM(CASE WHEN activity NOT IN (
            'Harvest Batch Created', 'Harvest Plan Approved', 'Harvest Batch Cancelled',
            'Field Team Assigned', 'Palm Ripeness Assessed', 'FFB Harvested', 'FFB Field Grading',
            'Harvest Collection Dispatched', 'FFB Loaded for Transport', 'Transport to Palm Oil Mill'
        ) THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS downstream_milling_cost
    FROM clean_events
    GROUP BY case_id
),
benchmarks AS (
    SELECT 
        COUNT(*) FILTER (WHERE is_rejected) AS baseline_rejected_lots,
        COUNT(*) FILTER (WHERE is_dispatched) AS baseline_dispatched_lots,
        AVG(revenue) FILTER (WHERE is_dispatched) AS avg_revenue_per_processed_lot,
        AVG(downstream_milling_cost) FILTER (WHERE is_dispatched) AS avg_marginal_milling_cost_per_lot,
        AVG(crop_sunk_cost) FILTER (WHERE is_rejected) AS avg_sunk_crop_cost_per_lot
    FROM lot_financials
),
scenario_assumptions AS (
    SELECT 
        0.15 AS rejection_reduction_rate,
        20000.00 AS implementation_cost,     -- NIR scanners + field grading training
        5000.00 AS additional_operating_cost  -- Calibration & inspection audits
)
SELECT 
    b.baseline_rejected_lots,
    ROUND(b.baseline_rejected_lots * s.rejection_reduction_rate, 2) AS lots_rescued_from_rejection,
    ROUND((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_revenue_per_processed_lot, 2) AS incremental_revenue_myr,
    ROUND((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_marginal_milling_cost_per_lot, 2) AS marginal_milling_cost_myr,
    s.implementation_cost AS implementation_cost_myr,
    s.additional_operating_cost AS additional_operating_cost_myr,
    ROUND(
        ((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_revenue_per_processed_lot)
        - ((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_marginal_milling_cost_per_lot)
        - s.implementation_cost - s.additional_operating_cost, 2
    ) AS net_financial_benefit_myr,
    ROUND(
        (((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_revenue_per_processed_lot)
        - ((b.baseline_rejected_lots * s.rejection_reduction_rate) * b.avg_marginal_milling_cost_per_lot)
        - s.implementation_cost - s.additional_operating_cost) * 4384.87, 2
    ) AS net_financial_benefit_idr
FROM benchmarks b 
CROSS JOIN scenario_assumptions s;
