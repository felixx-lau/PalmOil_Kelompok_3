# Palm Oil Processing — Data Engineering and Process Mining Laboratory

## Learning objectives
Distinguish genuine plantation/mill process variation from bad data; import and profile raw CSV in DuckDB;
standardize master-key references, timestamps, booleans and MYR figures; apply justified quarantine;
validate a case-centric event log, export it, and analyze process discovery and improvement in Celonis.

## Setup
Software: VS Code, DuckDB, SQL execution environment, CSV and access to a Celonis edition.
Extract `student/`; open that folder in VS Code. Execute SQL files in `sql/` in numerical order.
Use `read_csv(...,all_varchar=true)` to preserve the original source values. Never overwrite raw CSV.
Master data are clean. Do not use the number of records in a case/activity combination as a duplicate test.

## Required activities
1. **Import:** execute `00_import.sql`; verify the structure and individual raw rows.
2. **Profile:** extend `01_data_profiling.sql` to find activity/department variants, nulls, duplicate
   source event IDs, unexpected timestamps, numerical representations and master-key anomalies.
3. **Assess data quality:** completeness, uniqueness, consistency, validity, accuracy against authoritative
   masters, and relational integrity; explain the impact on downstream process mining.
4. **Deduplicate:** normalize `event_id` and inspect repeated records; do not delete legitimate new
   executions such as repeated field grading and lab testing, or valid concurrent processes.
5. **Repair:** use `TRIM`, `LOWER`, `UPPER`, `NULLIF`, `CASE`, `COALESCE`, `REPLACE`, safe casts,
   `TRY_STRPTIME`, and joins to clean masters. Preserve justified blanks and operational outliers.
6. **Validate:** check positivity of duration, nonnegative waits, process dependencies, referential
   integrity, cost equations, unique event IDs and recognized sale exactly once per dispatched lot.
   Quarantine unrecoverable records with supporting evidence; do not fabricate timestamps.
7. **Export:** build and verify `celonis_event_log_clean` in DuckDB, enable the export template,
   create `exports/celonis_event_log_clean.csv`, reimport and verify the CSV.
8. **Celonis:** import the verified CSV with `case_id`, `activity`, and `timestamp` mapped as
   Case ID, Activity and Event Timestamp. Menu labels vary by edition; consult your instance.
9. **Investigate:** discover variants, case cycle and activity throughput, waiting times,
   harvest/transport/mill bottlenecks, genuine quality rework, employee work allocation,
   FFB rejection, cost contribution and SLA compliance.
10. **Improve:** prioritize potential measures by cost, feasibility, product quality, safety,
    traceability and environmental protection; distinguish observed simulation outcomes from field reality.

## Student deliverables
(1) documented SQL cleaning code; (2) data-quality assessment; (3) correction decisions and quarantine log;
(4) validation queries/results; (5) cleaned Celonis CSV; (6) process-mining findings;
(7) prioritized and justified improvement proposal.

## Reflection
Can identical activity names represent valid repeat inspections? When can an FFB grade be Unknown?
Why may kernel recovery overlap with oil purification? How can unrealistic queue assumptions
distort resource-utilization estimates? Why must invoice and cash collection not double-count revenue?
