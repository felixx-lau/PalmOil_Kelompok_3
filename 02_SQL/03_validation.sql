-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 03_validation.sql
-- Purpose: Rigorous data quality and financial validation post-cleaning.
-- ====================================================================

-- 1. Identifier Uniqueness and Completeness
SELECT 
    COUNT(*) AS total_clean_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) FILTER (WHERE event_id IS NULL OR TRIM(event_id) = '') AS missing_event_ids,
    COUNT(*) FILTER (WHERE c.case_id IS NULL OR TRIM(c.case_id) = '') AS missing_case_ids,
    COUNT(DISTINCT c.case_id) AS total_cases,
    COUNT(DISTINCT m.case_id) AS master_cases_matched
FROM clean_events c
LEFT JOIN master_cases m ON c.case_id = m.case_id;

-- 2. Timestamp Chronological Sanity
SELECT 
    COUNT(*) FILTER (WHERE activity_start_time IS NULL) AS null_start_times,
    COUNT(*) FILTER (WHERE activity_end_time IS NULL) AS null_end_times,
    COUNT(*) FILTER (WHERE timestamp IS NULL) AS null_timestamps,
    COUNT(*) FILTER (WHERE activity_start_time > activity_end_time) AS inverted_durations,
    COUNT(*) FILTER (WHERE activity_duration_minutes <= 0) AS non_positive_durations,
    COUNT(*) FILTER (WHERE waiting_time_minutes < 0) AS negative_waiting_times
FROM clean_events;

-- 3. Financial Identity Integrity
SELECT 
    COUNT(*) FILTER (
        WHERE ABS((labor_cost + material_cost + equipment_cost + overhead_cost) - activity_total_cost) > 0.01
    ) AS cost_component_mismatches,
    COUNT(*) FILTER (
        WHERE ABS(profit_contribution - (revenue_allocated - activity_total_cost)) > 0.01
    ) AS contribution_identity_mismatches
FROM clean_events;

-- 4. Revenue Recognition Integrity
-- Revenue must only be positive on CPO Dispatch Confirmed, and negative on Authorized CPO Sales Allowance
SELECT 
    activity,
    COUNT(*) AS event_count,
    ROUND(SUM(revenue_allocated), 2) AS total_revenue_allocated,
    COUNT(*) FILTER (WHERE revenue_allocated > 0 AND activity != 'CPO Dispatch Confirmed') AS unauthorized_positive_revenue,
    COUNT(*) FILTER (WHERE revenue_allocated < 0 AND activity != 'Authorized CPO Sales Allowance') AS unauthorized_negative_revenue
FROM clean_events
GROUP BY activity
HAVING SUM(revenue_allocated) != 0;

-- 5. Referential Integrity Summary
SELECT 
    COUNT(*) FILTER (WHERE ac.activity IS NULL) AS unmapped_activities,
    COUNT(*) FILTER (WHERE dm.department_id IS NULL) AS unmapped_departments,
    COUNT(*) FILTER (WHERE c.employee_id IS NOT NULL AND em.employee_id IS NULL) AS unmapped_employees,
    COUNT(*) FILTER (WHERE c.resource_id IS NOT NULL AND rm.resource_id IS NULL) AS unmapped_resources
FROM clean_events c
LEFT JOIN master_activities ac ON c.activity = ac.activity
LEFT JOIN master_departments dm ON c.department_id = dm.department_id
LEFT JOIN master_employees em ON c.employee_id = em.employee_id
LEFT JOIN master_resources rm ON c.resource_id = rm.resource_id;

-- Machine-readable release gate. NULLs are failures, not SQL UNKNOWN passes.
CREATE OR REPLACE TABLE validation_checks AS
SELECT 'unique_event_ids' AS check_name, COUNT(*) - COUNT(DISTINCT event_id) AS failures FROM clean_events
UNION ALL SELECT 'required_cells', COUNT(*) FROM clean_events WHERE
 event_id IS NULL OR case_id IS NULL OR activity IS NULL OR department_id IS NULL
 OR employee_id IS NULL OR employee_role IS NULL OR resource_id IS NULL OR resource_type IS NULL
 OR activity_start_time IS NULL OR activity_end_time IS NULL OR timestamp IS NULL OR activity_ready_time IS NULL
 OR activity_duration_minutes IS NULL OR waiting_time_minutes IS NULL OR case_elapsed_time_minutes IS NULL
 OR activity_sla_minutes IS NULL OR sla_violation IS NULL OR rework_flag IS NULL
 OR labor_cost IS NULL OR material_cost IS NULL OR equipment_cost IS NULL OR overhead_cost IS NULL
 OR activity_total_cost IS NULL OR revenue_allocated IS NULL OR profit_contribution IS NULL
UNION ALL SELECT 'duration_identity', COUNT(*) FROM clean_events WHERE activity_duration_minutes IS DISTINCT FROM date_diff('second', activity_start_time, activity_end_time)/60.0 OR activity_duration_minutes <= 0
UNION ALL SELECT 'waiting_identity', COUNT(*) FROM clean_events WHERE waiting_time_minutes IS DISTINCT FROM date_diff('second', activity_ready_time, activity_start_time)/60.0 OR waiting_time_minutes < 0
UNION ALL SELECT 'end_timestamp', COUNT(*) FROM clean_events WHERE timestamp IS DISTINCT FROM activity_end_time
UNION ALL SELECT 'sla_identity', COUNT(*) FROM clean_events WHERE sla_violation IS DISTINCT FROM (waiting_time_minutes + activity_duration_minutes > activity_sla_minutes)
UNION ALL SELECT 'case_master_attributes', COUNT(*) FROM clean_events c LEFT JOIN master_cases m USING(case_id) WHERE m.case_id IS NULL OR c.case_type IS DISTINCT FROM m.case_type OR c.case_priority IS DISTINCT FROM m.case_priority OR c.case_complexity IS DISTINCT FROM m.case_complexity OR c.location IS DISTINCT FROM m.location OR c.harvest_batch_id IS DISTINCT FROM m.harvest_batch_id OR c.processing_lot_id IS DISTINCT FROM m.processing_lot_id OR c.estate_block IS DISTINCT FROM m.estate_block OR c.ffb_grade IS DISTINCT FROM m.ffb_grade
UNION ALL SELECT 'employee_resource_mapping', COUNT(*) FROM clean_events c LEFT JOIN master_employees e USING(employee_id) LEFT JOIN master_resources r ON c.resource_id=r.resource_id WHERE e.employee_id IS NULL OR r.resource_id IS NULL OR e.resource_id IS DISTINCT FROM c.resource_id OR r.employee_id IS DISTINCT FROM c.employee_id OR e.employee_role IS DISTINCT FROM c.employee_role OR r.resource_type IS DISTINCT FROM c.resource_type
UNION ALL SELECT 'activity_department_sla', COUNT(*) FROM clean_events c LEFT JOIN master_activities a USING(activity) LEFT JOIN master_departments d ON c.department_id=d.department_id WHERE a.activity IS NULL OR d.department_id IS NULL OR c.department_id IS DISTINCT FROM a.department_id OR c.department IS DISTINCT FROM d.department OR c.organizational_unit IS DISTINCT FROM d.organizational_unit OR c.activity_sla_minutes IS DISTINCT FROM TRY_CAST(a.activity_sla_minutes AS INTEGER) OR c.employee_role IS DISTINCT FROM a.required_role
UNION ALL SELECT 'facility_reference', COUNT(*) FROM clean_events c LEFT JOIN master_facilities f USING(facility_id) WHERE c.facility_id IS NOT NULL AND f.facility_id IS NULL
UNION ALL SELECT 'cost_identity', COUNT(*) FROM clean_events WHERE ABS(labor_cost+material_cost+equipment_cost+overhead_cost-activity_total_cost)>0.001 OR labor_cost<0 OR material_cost<0 OR equipment_cost<0 OR overhead_cost<0
UNION ALL SELECT 'profit_identity', COUNT(*) FROM clean_events WHERE ABS(revenue_allocated-activity_total_cost-profit_contribution)>0.001
UNION ALL SELECT 'revenue_activity', COUNT(*) FROM clean_events WHERE (revenue_allocated>0 AND activity<>'CPO Dispatch Confirmed') OR (revenue_allocated<0 AND activity<>'Authorized CPO Sales Allowance') OR currency IS DISTINCT FROM 'MYR'
UNION ALL SELECT 'case_elapsed_identity', COUNT(*) FROM (
 SELECT *, MIN(activity_ready_time) OVER(PARTITION BY case_id) AS inception FROM clean_events
) WHERE case_elapsed_time_minutes IS DISTINCT FROM date_diff('second',inception,activity_end_time)/60.0
UNION ALL SELECT 'sale_once_and_exclusive_outcome', COUNT(*) FROM (
 SELECT case_id, COUNT(*) FILTER(WHERE activity='CPO Dispatch Confirmed') AS dispatches,
 COUNT(*) FILTER(WHERE revenue_allocated>0) AS sales,
 COUNT(*) FILTER(WHERE activity='FFB Lot Rejected') AS rejects,
 COUNT(*) FILTER(WHERE activity='Harvest Batch Cancelled') AS cancels
 FROM clean_events GROUP BY case_id
) WHERE dispatches>1 OR sales<>dispatches OR dispatches+rejects+cancels<>1
UNION ALL SELECT 'case_start_and_close_once', COUNT(*) FROM (
 SELECT case_id, COUNT(*) FILTER(WHERE activity='Harvest Batch Created') AS starts,
 COUNT(*) FILTER(WHERE activity='Harvest Lot Closed') AS closes FROM clean_events GROUP BY case_id
) WHERE starts<>1 OR closes<>1;

-- Capacity-one checks allow oil/kernel parallelism on DISTINCT machines/workers.
INSERT INTO validation_checks
SELECT key_name || '_overlaps', COUNT(*) FILTER(WHERE activity_start_time < previous_end) FROM (
 SELECT 'facility' AS key_name, facility_id AS resource_key, activity_start_time,
 MAX(activity_end_time) OVER(PARTITION BY facility_id ORDER BY activity_start_time,event_id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS previous_end
 FROM clean_events WHERE facility_id IS NOT NULL
 UNION ALL
 SELECT 'employee', employee_id, activity_start_time,
 MAX(activity_end_time) OVER(PARTITION BY employee_id ORDER BY activity_start_time,event_id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
 FROM clean_events
) GROUP BY key_name;

SELECT * FROM validation_checks ORDER BY check_name;

-- Mandatory predecessors from source business_process_description.md.
-- Inspection bypasses remain business deviations, not ETL errors.
-- Additional repeat/rework sequencing and ready-time checks appear below.
CREATE OR REPLACE TEMP TABLE process_dependencies(activity, predecessor) AS
SELECT * FROM (VALUES
 ('Harvest Plan Approved','Harvest Batch Created'),
 ('Harvest Batch Cancelled','Harvest Plan Approved'),
 ('Field Team Assigned','Harvest Plan Approved'),
 ('Harvest Collection Dispatched','Field Team Assigned'),
 ('Palm Ripeness Assessed','Field Team Assigned'),
 ('FFB Harvested','Palm Ripeness Assessed'),
 ('FFB Field Grading','FFB Harvested'),
 ('FFB Loaded for Transport','FFB Field Grading'),
 ('FFB Loaded for Transport','Harvest Collection Dispatched'),
 ('Transport to Palm Oil Mill','FFB Loaded for Transport'),
 ('Mill Weighbridge Inbound','Transport to Palm Oil Mill'),
 ('Incoming FFB Quality Inspection','Mill Weighbridge Inbound'),
 ('FFB Lot Rejected','Incoming FFB Quality Inspection'),
 ('FFB Receipt Accepted','Mill Weighbridge Inbound'),
 ('Steam and Boiler Readiness Checked','FFB Receipt Accepted'),
 ('FFB Unloaded at Sterilizer Ramp','FFB Receipt Accepted'),
 ('FFB Sterilization Completed','FFB Unloaded at Sterilizer Ramp'),
 ('FFB Sterilization Completed','Steam and Boiler Readiness Checked'),
 ('FFB Threshing Completed','FFB Sterilization Completed'),
 ('Fruit Digestion Completed','FFB Threshing Completed'),
 ('Crude Oil Pressing Completed','Fruit Digestion Completed'),
 ('Oil Clarification Completed','Crude Oil Pressing Completed'),
 ('Oil Purification Completed','Oil Clarification Completed'),
 ('CPO Laboratory Tested','Oil Purification Completed'),
 ('CPO Quality Rework Applied','CPO Laboratory Tested'),
 ('Kernel Separation Completed','Crude Oil Pressing Completed'),
 ('Kernel Drying Completed','Kernel Separation Completed'),
 ('CPO Storage Tank Updated','CPO Laboratory Tested'),
 ('CPO Storage Tank Updated','Kernel Drying Completed'),
 ('CPO Transfer Authorized','CPO Storage Tank Updated'),
 ('CPO Loaded for Dispatch','CPO Transfer Authorized'),
 ('CPO Dispatch Confirmed','CPO Loaded for Dispatch'),
 ('CPO Sales Invoice Issued','CPO Dispatch Confirmed'),
 ('Buyer Remittance Matched','CPO Sales Invoice Issued'),
 ('Authorized CPO Sales Allowance','Buyer Remittance Matched')) AS p(activity,predecessor);
CREATE OR REPLACE TABLE dependency_failures AS
SELECT c.event_id,c.case_id,c.activity,d.predecessor
FROM clean_events c JOIN process_dependencies d USING(activity)
WHERE NOT EXISTS (SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id
 AND p.activity=d.predecessor AND p.activity_end_time<=c.activity_ready_time);
INSERT INTO validation_checks SELECT 'mandatory_predecessors',COUNT(*) FROM dependency_failures;

-- Ready equals an observed predecessor completion, allowing an explicitly
-- documented missing remittance caused by quarantine (never guessed/reinserted).
CREATE OR REPLACE TABLE dependency_exceptions AS
SELECT c.event_id,c.case_id,c.activity,'quarantined predecessor EVT-0000623' AS reason
FROM clean_events c WHERE c.case_id='PALM-000105' AND c.activity='Harvest Lot Closed'
 AND EXISTS(SELECT 1 FROM quarantined_events q WHERE UPPER(TRIM(q.event_id))='EVT-0000623');
INSERT INTO validation_checks
SELECT 'ready_predecessor_completion',COUNT(*) FROM clean_events c
WHERE c.activity<>'Harvest Batch Created'
 AND NOT EXISTS(SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id AND p.activity_end_time=c.activity_ready_time)
 AND NOT EXISTS(SELECT 1 FROM dependency_exceptions x WHERE x.event_id=c.event_id);
INSERT INTO validation_checks
SELECT 'inspection_order_when_present',COUNT(*) FROM clean_events c
WHERE c.activity='FFB Receipt Accepted'
 AND EXISTS(SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id AND p.activity='Incoming FFB Quality Inspection')
 AND NOT EXISTS(SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id AND p.activity='Incoming FFB Quality Inspection' AND p.activity_end_time<=c.activity_ready_time);
INSERT INTO validation_checks
SELECT 'rework_retest_order',COUNT(*) FROM clean_events c
WHERE c.activity='CPO Laboratory Tested' AND c.rework_flag
 AND NOT EXISTS(SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id AND p.activity='CPO Quality Rework Applied' AND p.activity_end_time=c.activity_ready_time);
INSERT INTO validation_checks
SELECT 'case_closure_dependency',COUNT(*) FROM clean_events c
WHERE c.activity='Harvest Lot Closed'
 AND NOT EXISTS(SELECT 1 FROM clean_events p WHERE p.case_id=c.case_id AND p.activity IN ('Harvest Batch Cancelled','FFB Lot Rejected','Buyer Remittance Matched','Authorized CPO Sales Allowance') AND p.activity_end_time=c.activity_ready_time)
 AND NOT EXISTS(SELECT 1 FROM dependency_exceptions x WHERE x.event_id=c.event_id);
SELECT * FROM validation_checks ORDER BY check_name;

-- Detect silent row loss from joins/deduplication and unexpected event insertions.
INSERT INTO validation_checks
SELECT 'source_event_conservation',COUNT(*) FROM (
 (SELECT UPPER(TRIM(event_id)) AS event_id FROM raw_events
  WHERE raw_row_id NOT IN (SELECT raw_row_id FROM quarantined_events)
  EXCEPT SELECT event_id FROM clean_events)
 UNION ALL
 (SELECT event_id FROM clean_events EXCEPT
  SELECT UPPER(TRIM(event_id)) FROM raw_events
  WHERE raw_row_id NOT IN (SELECT raw_row_id FROM quarantined_events))
);
INSERT INTO validation_checks
SELECT 'grade_estate_references',COUNT(*) FROM clean_events c
WHERE NOT EXISTS(SELECT 1 FROM master_ffb_grades g WHERE g.ffb_grade=c.ffb_grade)
 OR NOT EXISTS(SELECT 1 FROM master_estate_blocks b WHERE b.estate_block=c.estate_block);
INSERT INTO validation_checks
SELECT 'master_key_uniqueness', SUM(n-unique_n) FROM (
 SELECT COUNT(*) AS n,COUNT(DISTINCT case_id) AS unique_n FROM master_cases
 UNION ALL SELECT COUNT(*),COUNT(DISTINCT activity) FROM master_activities
 UNION ALL SELECT COUNT(*),COUNT(DISTINCT department_id) FROM master_departments
 UNION ALL SELECT COUNT(*),COUNT(DISTINCT employee_id) FROM master_employees
 UNION ALL SELECT COUNT(*),COUNT(DISTINCT resource_id) FROM master_resources
 UNION ALL SELECT COUNT(*),COUNT(DISTINCT facility_id) FROM master_facilities
);
SELECT * FROM validation_checks ORDER BY check_name;
