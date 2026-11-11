-- Run after 02_cleaning.sql, before validation/export, in the SAME DuckDB session.
-- Authoritative masters only: never infer an employee from activity frequency.
CREATE OR REPLACE TABLE cleaning_patch_audit AS
SELECT c.event_id, 'case_type' AS field_name, c.case_type AS old_value,
       m.case_type AS new_value, 'case_master.case_id' AS evidence
FROM clean_events c JOIN master_cases m USING (case_id)
WHERE c.case_type IS DISTINCT FROM m.case_type
UNION ALL
SELECT c.event_id, 'employee_id', c.employee_id, m.employee_id,
       'resource_master unique resource_id -> employee_id'
FROM clean_events c JOIN master_resources m USING (resource_id)
WHERE c.employee_id IS NULL
UNION ALL
SELECT c.event_id, 'resource_id', c.resource_id, m.resource_id,
       'employee_master unique employee_id -> resource_id'
FROM clean_events c JOIN master_employees m USING (employee_id)
WHERE c.resource_id IS NULL;

UPDATE clean_events c SET case_type = m.case_type
FROM master_cases m WHERE c.case_id = m.case_id;

UPDATE clean_events c SET employee_id = m.employee_id
FROM master_resources m
WHERE c.employee_id IS NULL AND c.resource_id = m.resource_id
  AND (SELECT COUNT(*) FROM master_resources x WHERE x.resource_id = c.resource_id) = 1;

UPDATE clean_events c SET resource_id = m.resource_id
FROM master_employees m
WHERE c.resource_id IS NULL AND c.employee_id = m.employee_id
  AND (SELECT COUNT(*) FROM master_employees x WHERE x.employee_id = c.employee_id) = 1;

UPDATE clean_events c SET employee_role = m.employee_role
FROM master_employees m WHERE c.employee_id = m.employee_id;
UPDATE clean_events c SET resource_type = m.resource_type
FROM master_resources m WHERE c.resource_id = m.resource_id;

-- The ready-time bug is fixed upstream in 02_cleaning.sql: preserve parsed_ready.
-- Source RAW-0000962 already supplies 2026-05-08 19:03:00 for EVT-0004091.
-- Cross-check: Field Team Assigned ends at 19:03 and start-ready = 278 minutes.
-- Also repair a table produced by the PREVIOUS version of 02_cleaning.sql.
UPDATE clean_events c
SET activity_ready_time = TRY_STRPTIME(r.activity_ready_time, '%Y-%m-%d %H:%M:%S')
FROM raw_events r
WHERE c.event_id = 'EVT-0004091' AND r.raw_row_id = 'RAW-0000962'
  AND UPPER(TRIM(r.event_id)) = c.event_id
  AND date_diff('second', TRY_STRPTIME(r.activity_ready_time, '%Y-%m-%d %H:%M:%S'),
                c.activity_start_time) / 60.0 = c.waiting_time_minutes;

-- old_value below records the CSV before this release; upstream is now fixed.
INSERT INTO cleaning_patch_audit
SELECT event_id, 'activity_ready_time', '2026-05-08 23:41:00',
       CAST(activity_ready_time AS VARCHAR),
       'RAW-0000962 ready time preserved; predecessor EVT-0003894 confirms it'
FROM clean_events WHERE event_id = 'EVT-0004091';

SELECT field_name, COUNT(*) AS repaired_events FROM cleaning_patch_audit
GROUP BY field_name ORDER BY field_name;
