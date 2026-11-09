# Data Quality & Cleaning Audit Report
## Tanjung Palma Agro-Industrial Estate — FFB Harvest-to-CPO Processing
**Author**: 24SI1 • GROUP 03  
**Dataset**: `raw_event_log.csv` (Synthetic Oil Palm Plantation & Mill Operations)  
**Output Target**: `01_DATA/cleaned/celonis_event_log_clean.csv`  

---

### 1. Executive Summary of Data Quality Findings
An exhaustive data engineering and profiling assessment was conducted on `raw_event_log.csv` (6.325 initial raw rows) using DuckDB SQL. The audit identified structural anomalies, data entry inconsistencies, duplicate logging records, and chronological inversions. Following justified, rule-based data cleaning and quarantine protocols:
- **Raw Input Rows**: 6.325
- **Source Duplicate Records Removed**: 145 (redundant extractions of identical event executions)
- **Quarantined Records**: 1 (`RAW-0005170`, event `EVT-0000623` with corrupted `'not-a-time'` values)
- **Final Valid Clean Events**: **6.179**
- **Unique Case Lots**: **230** (100% matched against `case_master.csv`)
- **Master Data Mapping Accuracy**: **100%** across activities, departments, employees, and resources.

---

### 2. Evaluation Across Data Quality Dimensions

| Dimension | Initial Raw Log Status | Remediation & Transformation | Final Clean Status |
|---|---|---|---|
| **Uniqueness** | 143 duplicated `event_id` strings (accounting for 288 rows / 145 redundant rows) | Applied `ROW_NUMBER() OVER (PARTITION BY UPPER(TRIM(event_id)) ...)` keeping the cleanest record | 100% unique `event_id` (6.179 unique records) |
| **Completeness** | 3 missing `material_cost` values; 1 missing employee role; 1 corrupted timestamp set | Reconstructed missing `material_cost` via cost balance equation; quarantined corrupted timestamps | 0 missing critical identifiers or financial cells |
| **Validity** | Strings containing currency symbols (`RM`, `MYR `); 1 row with `'not-a-time'`; boolean mixed cases (`N`, `true`, `1`) | Extracted pure numeric decimals using regex; normalized booleans to boolean literals; quarantined unparseable row | 100% compliant data types (DECIMAL, TIMESTAMP, BOOLEAN) |
| **Consistency** | 17 rows with inverted start/end timestamps (`start > end`); mixed date formats (`YYYY-MM-DD`, `YYYY/MM/DD`, `DD/MM/YYYY`) | Day-first aware multi-format parsing; chronological swapping of inverted pairs | 100% chronologically valid (`start <= end = timestamp`) |
| **Referential Integrity** | Lowercase/untrimmed activities (`cpo laboratory tested`), non-standard departments (`Plantation Planning Dept.`) | Case-insensitive trimming and authoritative lookup join against master catalogs | 100% foreign key match to authoritative masters |

---

### 3. Detailed Data Cleaning Decisions & Audit Trail

#### 3.1 Deduplication of Event Logging (145 Redundant Rows)
- **Observation**: 143 normalized `event_id` keys appeared more than once. In all instances, these represented extraction duplicates of the same execution (identical case, activity, and start/end window), differing only by casing (`evt-0000057` vs `EVT-0000057`) or whitespace.
- **Action**: Normalized `event_id` using `UPPER(TRIM(event_id))` and filtered using window ranking prioritizing records without currency formatting anomalies. Exactly 145 duplicate rows were removed.
- **Integrity Rule**: Distinct executions of legitimate rework (such as repeat field grading or re-testing) possess unique, distinct `event_id` values and were strictly preserved.

#### 3.2 Quarantine Log (1 Record Excluded)
- **Quarantined Row**: `RAW-0005170`
- **Event ID**: `EVT-0000623` | **Case ID**: `PALM-000105`
- **Activity**: `Buyer Remittance Matched`
- **Corrupted Fields**: `activity_start_time = 'not-a-time'`, `activity_end_time = 'not-a-time'`, `timestamp = 'not-a-time'`, `activity_ready_time = 'not-a-time'`.
- **Justification**: In strict adherence to laboratory instructions (*"quarantine unrecoverable records with supporting evidence; do not fabricate timestamps"*), this record cannot have its timestamps synthetically guessed without compromising process mining time-distance accuracy. It was isolated to `quarantined_events`.

#### 3.3 Chronological Inversion Repair (17 Records)
- **Observation**: In 17 rows, `activity_start_time` was recorded chronologically after `activity_end_time` (e.g. `RAW-0000173`: start = 13:27, end = 13:07).
- **Diagnostic Verification**: In every one of these 17 cases:
  1. `start_time - end_time` exactly matched the recorded positive `activity_duration_minutes` (e.g. 20 minutes).
  2. The process mining `timestamp` column matched `activity_start_time`.
  3. `activity_ready_time` matched `activity_end_time`.
- **Action**: The two timestamp fields were inverted during ETL extraction. The values were safely swapped: `start_time := parsed_end` and `end_time := parsed_start`, ensuring `duration = end - start > 0` and `timestamp = end`.

#### 3.4 Financial Formatting & Missing Material Cost Repair
- **Currency Symbols**: 17 entries contained text prefixes (`RM10.83`, `MYR 49.07`, `RM0.00`). These were stripped via regex `REGEXP_REPLACE(val, '[^0-9.-]', '', 'g')` and cast to `DECIMAL(18,2)`.
- **Missing Material Cost (3 Rows)**:
  - `RAW-0001714` (CPO Storage Tank Updated): Total 70.97, Labor 44.75, Equip 3.30, Overhead 22.92 $\rightarrow$ Implied Material Cost = **0.00 MYR**.
  - `RAW-0003142` (Transport to Palm Oil Mill): Total 469.67, Labor 42.50, Equip 124.90, Overhead 28.96 $\rightarrow$ Implied Material Cost = **273.31 MYR** (fuel/consumables).
  - `RAW-0005350` (FFB Threshing Completed): Total 382.68, Labor 47.75, Equip 73.35, Overhead 24.66 $\rightarrow$ Implied Material Cost = **236.92 MYR**.
- **Result**: Post-cleaning reconciliation verified:
  $$\text{activity\_total\_cost} = \text{labor\_cost} + \text{material\_cost} + \text{equipment\_cost} + \text{overhead\_cost} \quad (\Delta = 0.00)$$
  $$\text{profit\_contribution} = \text{revenue\_allocated} - \text{activity\_total\_cost} \quad (\Delta = 0.00)$$

---

### 4. Verification & Validation SQL Summary
Executing `02_SQL/03_validation.sql` on `clean_events` confirms:
1. `missing_identifiers` = **0**
2. `invalid_financial_rows` = **0**
3. `inconsistent_contribution_rows` = **0**
4. `inverted_durations` = **0**
5. `negative_waiting_times` = **0**
6. `master_cases_matched` = **230 / 230 (100%)**
7. `unmapped_activities` = **0**
