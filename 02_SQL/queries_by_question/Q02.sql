-- Q02: FFB Outcomes and Cost Leakage
-- Input: clean_events from the verified cleaned CSV, in the same DuckDB session.
-- Horizon: 24-month intake window, October 2024 to September 2026; times are UTC.
-- All monetary aggregates use DECIMAL. FX follows the assignment: 4384.87 IDR/MYR.

CREATE OR REPLACE TEMP VIEW q02_cases AS
SELECT case_id,
       BOOL_OR(activity = 'Harvest Batch Cancelled') AS is_cancelled,
       BOOL_OR(activity = 'FFB Lot Rejected') AS is_rejected,
       BOOL_OR(activity = 'CPO Dispatch Confirmed') AS is_dispatched,
       BOOL_OR(activity = 'FFB Harvested') AS is_harvested,
       SUM(CASE WHEN activity = 'FFB Harvested'
                THEN TRY_CAST(material_cost AS DECIMAL(18,2)) ELSE 0 END) AS crop_cost,
       SUM(CASE WHEN activity = 'FFB Harvested'
                THEN TRY_CAST(labor_cost AS DECIMAL(18,2))
                   + TRY_CAST(equipment_cost AS DECIMAL(18,2))
                   + TRY_CAST(overhead_cost AS DECIMAL(18,2)) ELSE 0 END) AS harvest_operations_cost,
       SUM(CASE WHEN activity IN ('Harvest Batch Created', 'Harvest Plan Approved',
                     'Harvest Batch Cancelled', 'Field Team Assigned',
                     'Palm Ripeness Assessed', 'FFB Field Grading')
                THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS other_plantation_cost,
       SUM(CASE WHEN activity IN ('Harvest Collection Dispatched',
                     'FFB Loaded for Transport', 'Transport to Palm Oil Mill')
                THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS transport_cost,
       SUM(CASE WHEN activity IN ('Mill Weighbridge Inbound',
                     'Incoming FFB Quality Inspection', 'FFB Lot Rejected',
                     'FFB Receipt Accepted', 'FFB Unloaded at Sterilizer Ramp')
                THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS reception_cost,
       SUM(CASE WHEN activity IN ('Steam and Boiler Readiness Checked',
                     'FFB Sterilization Completed', 'FFB Threshing Completed',
                     'Fruit Digestion Completed', 'Crude Oil Pressing Completed',
                     'Oil Clarification Completed', 'Oil Purification Completed',
                     'CPO Laboratory Tested', 'CPO Quality Rework Applied',
                     'Kernel Separation Completed', 'Kernel Drying Completed',
                     'CPO Storage Tank Updated')
                THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS milling_cost,
       SUM(CASE WHEN activity IN ('CPO Transfer Authorized', 'CPO Loaded for Dispatch',
                     'CPO Dispatch Confirmed', 'CPO Sales Invoice Issued',
                     'Buyer Remittance Matched', 'Authorized CPO Sales Allowance',
                     'Harvest Lot Closed')
                THEN TRY_CAST(activity_total_cost AS DECIMAL(18,2)) ELSE 0 END) AS dispatch_finance_closure_cost,
       SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS total_cost,
       SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) AS total_revenue,
       SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) AS total_contribution
FROM clean_events GROUP BY case_id;

CREATE OR REPLACE TEMP VIEW q02_outcomes AS
SELECT *, CASE
    WHEN CAST(is_cancelled AS INTEGER) + CAST(is_rejected AS INTEGER)
       + CAST(is_dispatched AS INTEGER) <> 1 THEN 'Unclassified or conflicting'
    WHEN is_cancelled THEN 'Cancelled'
    WHEN is_rejected THEN 'Rejected'
    WHEN is_dispatched THEN 'Processed / Dispatched'
END AS outcome FROM q02_cases;

-- Result 01: outcomes and reconciled MYR/IDR totals.
-- Denominator for percentages is all cases, including cancellations.
SELECT outcome, COUNT(*) AS lots,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM q02_cases), 2) AS pct_all_cases,
       SUM(total_revenue) AS revenue_myr, SUM(total_cost) AS cost_myr,
       SUM(total_contribution) AS contribution_myr,
       ROUND(SUM(total_revenue) * 4384.87, 2) AS revenue_idr,
       ROUND(SUM(total_cost) * 4384.87, 2) AS cost_idr,
       ROUND(SUM(total_contribution) * 4384.87, 2) AS contribution_idr
FROM q02_outcomes GROUP BY outcome ORDER BY lots DESC;

-- Result 02: exhaustive, non-overlapping cost breakdown.
-- Closure of rejected/cancelled lots is administrative closure, not milling.
SELECT component,
       SUM(amount) FILTER (WHERE outcome = 'Processed / Dispatched') AS processed_myr,
       SUM(amount) FILTER (WHERE outcome = 'Rejected') AS rejected_myr,
       SUM(amount) FILTER (WHERE outcome = 'Cancelled') AS cancelled_myr,
       SUM(amount) AS total_myr
FROM q02_outcomes,
LATERAL (VALUES
    ('1. Crop production material at harvest', crop_cost),
    ('2. Harvest labor equipment overhead', harvest_operations_cost),
    ('3. Other plantation planning grading cancellation', other_plantation_cost),
    ('4. Transport logistics', transport_cost),
    ('5. Weighbridge reception inspection', reception_cost),
    ('6. Milling processing storage update', milling_cost),
    ('7. Dispatch finance lot closure', dispatch_finance_closure_cost)
) AS components(component, amount)
GROUP BY component ORDER BY component;

-- Result 03: two distinct rejection-rate denominators.
SELECT COUNT(*) AS all_cases,
       COUNT(*) FILTER (WHERE is_harvested) AS harvested_cases,
       COUNT(*) FILTER (WHERE is_rejected) AS rejected_cases,
       ROUND(COUNT(*) FILTER (WHERE is_rejected) * 100.0 / COUNT(*), 2) AS rejection_pct_all_cases,
       ROUND(COUNT(*) FILTER (WHERE is_rejected AND is_harvested) * 100.0
             / NULLIF(COUNT(*) FILTER (WHERE is_harvested), 0), 2) AS rejection_pct_harvested_cases
FROM q02_cases;

-- Result 04: upper-bound COUNTERFACTUAL, not recorded loss or expected cash savings.
-- Uses rounded processed-lot contribution 8315.92 as the explicit benchmark,
-- retaining comparability to the former 953023.09 claim.
-- Assumes ALL rejected lots could meet quality and earn the benchmark;
-- actual implementation costs and feasibility are not established by this exercise.
WITH benchmark AS (
    SELECT COUNT(*) FILTER (WHERE is_rejected) AS rejected_lots,
           SUM(total_cost) FILTER (WHERE is_rejected) AS recorded_rejected_cost,
           CAST(ROUND(AVG(total_contribution) FILTER (WHERE is_dispatched), 2)
                AS DECIMAL(18,2)) AS rounded_processed_contribution_per_lot
    FROM q02_cases
)
SELECT *,
       rejected_lots * rounded_processed_contribution_per_lot AS hypothetical_positive_contribution_myr,
       recorded_rejected_cost + rejected_lots * rounded_processed_contribution_per_lot AS upper_bound_scenario_gap_myr,
       ROUND((recorded_rejected_cost + rejected_lots * rounded_processed_contribution_per_lot) * 4384.87, 2) AS upper_bound_scenario_gap_idr
FROM benchmark;

-- Result 05: validation must show zero for all discrepancy counts.
SELECT COUNT(*) FILTER (WHERE outcome = 'Unclassified or conflicting') AS outcome_errors,
       COUNT(*) FILTER (WHERE ABS(total_cost - (crop_cost + harvest_operations_cost
           + other_plantation_cost + transport_cost + reception_cost + milling_cost
           + dispatch_finance_closure_cost)) > 0.01) AS cost_breakdown_errors,
       COUNT(*) FILTER (WHERE ABS(total_revenue - total_cost - total_contribution) > 0.01) AS contribution_errors,
       COUNT(*) FILTER (WHERE is_rejected AND NOT is_harvested) AS rejected_without_harvest,
       COUNT(*) FILTER (WHERE is_cancelled AND is_harvested) AS cancelled_after_harvest,
       SUM(total_cost) AS baseline_cost_myr, SUM(total_revenue) AS baseline_revenue_myr,
       SUM(total_contribution) AS baseline_contribution_myr
FROM q02_outcomes;

-- Result 06: illustrative 15% RELATIVE reduction, fixed 218 harvested-lot volume.
-- Fractional cases are expected-volume equivalents; no financial benefit asserted here.
SELECT COUNT(*) FILTER (WHERE is_harvested) AS harvested_cases,
       COUNT(*) FILTER (WHERE is_rejected) AS baseline_rejected_cases,
       COUNT(*) FILTER (WHERE is_rejected) * 0.15 AS rescued_lot_equivalents,
       COUNT(*) FILTER (WHERE is_rejected) * 0.85 AS remaining_rejected_lot_equivalents,
       ROUND((COUNT(*) FILTER (WHERE is_rejected) * 0.85) * 100.0
          / NULLIF(COUNT(*) FILTER (WHERE is_harvested), 0), 2) AS to_be_rejection_pct_harvested
FROM q02_cases;
