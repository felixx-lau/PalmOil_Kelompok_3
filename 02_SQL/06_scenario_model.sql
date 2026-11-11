CREATE OR REPLACE TEMP VIEW model_events AS SELECT * REPLACE (CAST(activity_total_cost AS DECIMAL(18,2)) AS activity_total_cost, CAST(revenue_allocated AS DECIMAL(18,2)) AS revenue_allocated, CAST(profit_contribution AS DECIMAL(18,2)) AS profit_contribution, CAST(equipment_cost AS DECIMAL(18,2)) AS equipment_cost) FROM clean_events;
-- Shared, conditional what-if model for Q07-Q10. All amounts MYR.
-- Horizon is the full 24-month intake cohort, not a calendar-year forecast.
-- Annual maintenance OPEX is charged twice; CAPEX once. FX is assignment input.
-- This is net benefit after investment, not accounting profit after depreciation.
CREATE OR REPLACE TEMP VIEW model_baseline AS
SELECT SUM(activity_total_cost)::DECIMAL(18,2) AS cost,
       SUM(revenue_allocated)::DECIMAL(18,2) AS revenue,
       SUM(profit_contribution)::DECIMAL(18,2) AS contribution
FROM model_events;
CREATE OR REPLACE TEMP VIEW model_lots AS
SELECT case_id, BOOL_OR(activity='CPO Dispatch Confirmed') AS dispatched,
       BOOL_OR(activity='FFB Lot Rejected') AS rejected,
       SUM(revenue_allocated) AS revenue, SUM(activity_total_cost) AS cost,
       -- Rescue proxy: post-acceptance work only. Already-incurred weighbridge,
       -- inspection, rejection and lot closure are not charged again or recovered.
       SUM(CASE WHEN activity IN ('FFB Receipt Accepted','FFB Unloaded at Sterilizer Ramp',
        'Steam and Boiler Readiness Checked','FFB Sterilization Completed',
        'FFB Threshing Completed','Fruit Digestion Completed','Crude Oil Pressing Completed',
        'Oil Clarification Completed','Oil Purification Completed','CPO Laboratory Tested',
        'CPO Quality Rework Applied','Kernel Separation Completed','Kernel Drying Completed',
        'CPO Storage Tank Updated','CPO Transfer Authorized','CPO Loaded for Dispatch',
        'CPO Dispatch Confirmed','CPO Sales Invoice Issued','Buyer Remittance Matched',
        'Authorized CPO Sales Allowance') THEN activity_total_cost ELSE 0 END) AS rescue_processing_cost
FROM model_events GROUP BY case_id;
CREATE OR REPLACE TEMP VIEW model_benchmarks AS
SELECT COUNT(*) FILTER(WHERE rejected) AS rejected_lots,
 COUNT(*) FILTER(WHERE dispatched) AS processed_lots,
 AVG(revenue) FILTER(WHERE dispatched) AS processed_revenue,
 AVG(cost) FILTER(WHERE dispatched) AS processed_cost,
 AVG(rescue_processing_cost) FILTER(WHERE dispatched) AS rescue_processing_cost
FROM model_lots;
CREATE OR REPLACE TEMP VIEW model_inputs AS
SELECT
 (SELECT SUM(equipment_cost) FROM model_events WHERE activity IN
 ('Harvest Collection Dispatched','FFB Loaded for Transport','Transport to Palm Oil Mill')) AS truck_equipment,
 (SELECT SUM(activity_total_cost) FROM model_events WHERE
 activity IN ('CPO Quality Rework Applied','CPO Laboratory Tested') AND
 (rework_flag OR activity ILIKE '%rework%')) AS cpo_rework_cost,
 (SELECT -SUM(revenue_allocated) FROM model_events WHERE activity='Authorized CPO Sales Allowance') AS allowances;
CREATE OR REPLACE TEMP VIEW model_initiatives AS
SELECT 'Q07_SCHED' AS scenario_id, 'Transport scheduling pilot' AS scenario_name,
 0::DECIMAL(18,2) AS incremental_revenue_myr,
 ROUND(truck_equipment*0.12*0.20,2)::DECIMAL(18,2) AS avoidable_savings_myr,
 0::DECIMAL(18,2) AS marginal_processing_cost_myr,
 6000::DECIMAL(18,2) AS implementation_cost_myr,
 2400::DECIMAL(18,2) AS operating_cost_myr FROM model_inputs
UNION ALL
SELECT 'Q08_GRADE','Reject prevention pilot', ROUND(rejected_lots*0.15*processed_revenue,2),0,
 ROUND(rejected_lots*0.15*rescue_processing_cost,2),20000,10000 FROM model_benchmarks
UNION ALL
SELECT 'Q09_CAPEX_FIXED','Capacity scenario fixed demand',0,0,0,110000,30000
UNION ALL
SELECT 'Q09_CAPEX_GROWTH','Capacity scenario conditional growth',
 ROUND(processed_lots*0.15*processed_revenue,2),0,
 ROUND(processed_lots*0.15*processed_cost,2),110000,30000 FROM model_benchmarks
UNION ALL
-- Excludes field grading (Q08) to reduce benefit overlap. Mandatory retesting stays.
SELECT 'Q10_QUALITY','CPO quality prevention pilot',ROUND(allowances*0.50,2),
 ROUND(cpo_rework_cost*0.40,2),0,8000,3000 FROM model_inputs;
CREATE OR REPLACE TEMP VIEW model_portfolio AS
SELECT * FROM model_initiatives
UNION ALL
SELECT 'Q10_COMBINED','Combined reject and CPO quality pilots',
 SUM(incremental_revenue_myr),SUM(avoidable_savings_myr),SUM(marginal_processing_cost_myr),
 SUM(implementation_cost_myr),SUM(operating_cost_myr)
FROM model_initiatives WHERE scenario_id IN ('Q08_GRADE','Q10_QUALITY');
CREATE OR REPLACE TEMP VIEW scenario_comparison AS
WITH cases AS (
 SELECT * FROM model_portfolio
 UNION ALL SELECT 'AS_IS','Observed baseline',0,0,0,0,0
 UNION ALL SELECT 'NO_ACTION','Conditional repeated cohort',0,0,0,0,0
) , typed_cases AS (
 SELECT scenario_id,scenario_name,
 CAST(incremental_revenue_myr AS DECIMAL(18,2)) AS incremental_revenue_myr,
 CAST(avoidable_savings_myr AS DECIMAL(18,2)) AS avoidable_savings_myr,
 CAST(marginal_processing_cost_myr AS DECIMAL(18,2)) AS marginal_processing_cost_myr,
 CAST(implementation_cost_myr AS DECIMAL(18,2)) AS implementation_cost_myr,
 CAST(operating_cost_myr AS DECIMAL(18,2)) AS operating_cost_myr FROM cases
), amounts AS (
 SELECT p.*, b.revenue+incremental_revenue_myr AS revenue_myr,
 b.cost+marginal_processing_cost_myr+implementation_cost_myr+operating_cost_myr-avoidable_savings_myr AS cost_myr,
 incremental_revenue_myr+avoidable_savings_myr-marginal_processing_cost_myr-implementation_cost_myr-operating_cost_myr AS net_financial_benefit_myr
 FROM typed_cases p CROSS JOIN model_baseline b
)
SELECT scenario_id,scenario_name,revenue_myr,ROUND(revenue_myr*4384.87,2) AS revenue_idr,
 cost_myr,ROUND(cost_myr*4384.87,2) AS cost_idr,
 avoidable_savings_myr,ROUND(avoidable_savings_myr*4384.87,2) AS avoidable_savings_idr,
 incremental_revenue_myr,ROUND(incremental_revenue_myr*4384.87,2) AS incremental_revenue_idr,
 marginal_processing_cost_myr,ROUND(marginal_processing_cost_myr*4384.87,2) AS marginal_processing_cost_idr,
 implementation_cost_myr,ROUND(implementation_cost_myr*4384.87,2) AS implementation_cost_idr,
 operating_cost_myr,ROUND(operating_cost_myr*4384.87,2) AS operating_cost_idr,
 net_financial_benefit_myr,ROUND(net_financial_benefit_myr*4384.87,2) AS net_financial_benefit_idr,
 revenue_myr-cost_myr AS to_be_contribution_myr,
 ROUND((revenue_myr-cost_myr)*4384.87,2) AS to_be_contribution_idr,
 24 AS horizon_months
FROM amounts;
CREATE OR REPLACE TEMP VIEW model_sensitivity AS
SELECT 'Q08 reject reduction' AS initiative, r AS effectiveness,
 ROUND(rejected_lots*r*(processed_revenue-rescue_processing_cost)-30000,2) AS net_benefit_myr
FROM model_benchmarks CROSS JOIN (VALUES (0.0),(0.05),(0.10),(0.15),(0.20)) AS x(r)
UNION ALL
SELECT 'Q10 allowance reduction (40% CPO rework fixed)',r,
 ROUND(cpo_rework_cost*0.40+allowances*r-11000,2)
FROM model_inputs CROSS JOIN (VALUES (0.0),(0.10),(0.25),(0.50),(0.75)) AS x(r);
