-- Q08 conditional reject prevention, 15% RELATIVE reduction, 24 months.
SELECT *, rejected_lots*0.15 AS rescued_lot_equivalents FROM model_benchmarks;

-- Requires 06_scenario_model.sql in the same connection.
SELECT * FROM scenario_comparison WHERE scenario_id LIKE 'Q08_GRADE%' ORDER BY scenario_id;
