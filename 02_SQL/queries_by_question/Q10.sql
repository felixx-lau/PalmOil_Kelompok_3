-- Q10 shared conditional model; 24-month OPEX, no automatic payback claim.
-- Rank standalone programs only; combined portfolio is not an extra benefit.
SELECT ROW_NUMBER() OVER(ORDER BY net_financial_benefit_myr DESC,scenario_id) AS priority_rank,*
FROM scenario_comparison WHERE scenario_id IN ('Q07_SCHED','Q08_GRADE','Q09_CAPEX_FIXED','Q10_QUALITY')
ORDER BY priority_rank;
SELECT * FROM scenario_comparison WHERE scenario_id IN ('AS_IS','NO_ACTION','Q10_COMBINED') ORDER BY scenario_id;
SELECT * FROM model_sensitivity ORDER BY initiative,effectiveness;
SELECT COUNT(*) AS financial_reconciliation_errors FROM scenario_comparison
WHERE ABS(revenue_myr-cost_myr-to_be_contribution_myr)>0.001
 OR ABS(to_be_contribution_myr-(SELECT contribution FROM model_baseline)-net_financial_benefit_myr)>0.001;
