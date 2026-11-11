# Student Data Dictionary — Palm Oil Event Log

UTF-8 CSV, comma delimiter, header row. Import all raw columns initially as VARCHAR.
**UTC timestamps:** canonical `YYYY-MM-DD HH:MM:SS`; alternate `YYYY/MM/DD HH:MM:SS` and `DD/MM/YYYY HH:MM`.
**Dates are always day-first if the day appears first.** No MM/DD/YYYY source dates.
**MYR amounts:** decimal point, 2 decimal places, no group separator or currency prefix in canonical clean data.
**Boolean:** canonical `true` / `false`; raw representations may be `Y/N`, `Yes/No`, `1/0` or uppercase.
**Empty exception_type** is valid if exception_flag is false; an empty facility_id is also valid for tasks without equipment.

| Column | Target type | Description |
|---|---|---|
| raw_row_id | VARCHAR | Unique source extract row ID, assigned after all source records were shuffled. |
| event_id | VARCHAR | Stable ID for one activity execution. Repeated normalized event_id means a repeated source record. |
| case_id | VARCHAR | Case-centric FFB harvest-to-CPO lot identifier. |
| activity | VARCHAR | Recorded completed activity; see the authoritative activity catalog. |
| activity_start_time | TIMESTAMP | Execution began; positive duration must follow. |
| activity_end_time | TIMESTAMP | Execution completed. |
| timestamp | TIMESTAMP | Process-mining event timestamp; equals normalized end time. |
| activity_ready_time | TIMESTAMP | Predecessor dependencies completed and queueing became possible. |
| department_id | VARCHAR | Master department key. |
| department | VARCHAR | Master department name. |
| employee_id | VARCHAR | Synthetic worker duty-slot identifier. |
| employee_role | VARCHAR | Master required skill category. |
| resource_id | VARCHAR | Workstation/tool kit assigned to an employee. |
| resource_type | VARCHAR | Authoritative workstation classification. |
| organizational_unit | VARCHAR | Parent operating division. |
| facility_id | VARCHAR | Capacity-one mill machine, truck, or yard station ID. Legitimately blank without a facility. |
| activity_duration_minutes | DECIMAL(18,2) | End minus start (elapsed minutes). |
| waiting_time_minutes | DECIMAL(18,2) | Start minus ready (elapsed minutes). |
| case_elapsed_time_minutes | DECIMAL(18,2) | Activity end minus case inception. |
| activity_sla_minutes | INTEGER | Target ready-to-completion minutes. |
| sla_violation | BOOLEAN | Waiting plus activity duration exceeded SLA. |
| rework_flag | BOOLEAN | Legitimate re-execution of an activity with a distinct event identifier. |
| activity_status | VARCHAR | Completion status of this recorded event. |
| labor_cost | DECIMAL(18,2) | MYR workforce expense for this completed operation. |
| material_cost | DECIMAL(18,2) | MYR allocated FFB growing/feedstock cost at harvest and subsequent fuel, process chemicals and consumables. |
| equipment_cost | DECIMAL(18,2) | MYR machinery, trucks and tool utilization allocation. |
| overhead_cost | DECIMAL(18,2) | MYR allocated activity overhead. |
| activity_total_cost | DECIMAL(18,2) | Sum of four cost components in MYR. |
| revenue_allocated | DECIMAL(18,2) | MYR net sale recognition allocated only at CPO dispatch or documented negative allowance. |
| profit_contribution | DECIMAL(18,2) | Revenue allocated minus activity cost (MYR). |
| currency | VARCHAR | ISO 4217 code MYR (Malaysian ringgit; RM). |
| case_type | VARCHAR | Case category known when harvest lot is initiated. |
| case_priority | VARCHAR | Operational scheduling priority at creation. |
| case_complexity | VARCHAR | Processing complexity estimated at case creation. |
| location | VARCHAR | Fictional synthetic estate/mill organization. |
| harvest_batch_id | VARCHAR | Field harvest-batch identifier. |
| processing_lot_id | VARCHAR | Downstream CPO processing lot identifier (preallocated). |
| estate_block | VARCHAR | Source estate block; see clean estate_block_master. |
| ffb_grade | VARCHAR | Provisional FFB grade; Unknown is an intentional valid reference grade pending final inspection. |
| exception_flag | BOOLEAN | Genuine business exception; not itself a source-level data-quality flag. |
| exception_type | VARCHAR | Optional genuine business-exception description, legitimately blank for normal events. |
