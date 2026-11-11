-- Q09 capacity is not automatically output. +15% service RATE assumes
-- cycle time / 1.15 only if the upgrade actually increases processing speed.
SELECT COUNT(*) AS executions, ROUND(AVG(activity_duration_minutes),2) AS processing_minutes, ROUND(AVG(activity_duration_minutes)/1.15,2) AS assumed_speedup_processing_minutes, ROUND(SUM(waiting_time_minutes)/60.0,2) AS waiting_hours FROM clean_events WHERE activity='FFB Sterilization Completed';
SELECT processed_lots,processed_lots*0.15 AS additional_lot_equivalents,processed_lots*1.15 AS total_lot_equivalents FROM model_benchmarks;

-- Requires 06_scenario_model.sql in the same connection.
SELECT * FROM scenario_comparison WHERE scenario_id LIKE 'Q09_CAPEX%' ORDER BY scenario_id;
