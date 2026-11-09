-- ====================================================================
-- QUESTION 01: HARVEST-TO-CPO PROCESS DISCOVERY
-- Group: 24SI1 • GROUP 03
-- Folder: 02_SQL/queries_by_question/Q01.sql
-- Description: Process map traces, dominant process variants, throughput time,
--              operational cost, and profit contribution comparison.
-- ====================================================================

-- Timestamp ties use event_id as a deterministic SQL tie-breaker.
-- Celonis evidence: 62 / 23 / 17 cases; SQL: 61 / 23 / 17.
CREATE OR REPLACE TEMP VIEW q01_case_traces AS
SELECT case_id,
       STRING_AGG(activity, ' -> ' ORDER BY TRY_CAST(timestamp AS TIMESTAMP), event_id) AS variant_path,
       MIN(TRY_CAST(timestamp AS TIMESTAMP)) AS case_start,
       MAX(TRY_CAST(timestamp AS TIMESTAMP)) AS case_end,
       date_diff('minute', MIN(TRY_CAST(timestamp AS TIMESTAMP)),
                 MAX(TRY_CAST(timestamp AS TIMESTAMP))) / 60.0 AS throughput_hours,
       SUM(TRY_CAST(activity_total_cost AS DECIMAL(18,2))) AS total_case_cost,
       SUM(TRY_CAST(revenue_allocated AS DECIMAL(18,2))) AS total_case_revenue,
       SUM(TRY_CAST(profit_contribution AS DECIMAL(18,2))) AS case_contribution
FROM clean_events GROUP BY case_id;

WITH case_traces AS (
    SELECT * FROM q01_case_traces
),
variant_aggregation AS (
    SELECT 
        variant_path,
        COUNT(*) AS case_volume,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM q01_case_traces), 2) AS case_percentage,
        ROUND(AVG(throughput_hours), 2) AS avg_throughput_hours,
        ROUND(MIN(throughput_hours), 2) AS min_throughput_hours,
        ROUND(MAX(throughput_hours), 2) AS max_throughput_hours,
        ROUND(AVG(total_case_cost), 2) AS avg_operational_cost,
        ROUND(AVG(total_case_revenue), 2) AS avg_revenue,
        ROUND(AVG(case_contribution), 2) AS avg_profit_contribution,
        ROUND(SUM(case_contribution), 2) AS total_variant_contribution
    FROM case_traces
    GROUP BY variant_path
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY case_volume DESC, variant_path) AS variant_rank,
    case_volume,
    case_percentage,
    avg_throughput_hours,
    avg_operational_cost,
    avg_revenue,
    avg_profit_contribution,
    total_variant_contribution,
    variant_path
FROM variant_aggregation
ORDER BY case_volume DESC, variant_path
LIMIT 10;


-- Compare exposure to the surge window, using case_start for cohort membership.
-- The window is inclusive of 25 April through 31 May 2026.
CREATE OR REPLACE TEMP VIEW q01_ranked_variants AS
SELECT variant_path, ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, variant_path) AS variant_rank
FROM q01_case_traces GROUP BY variant_path;

SELECT r.variant_rank, COUNT(*) AS cases,
       COUNT(*) FILTER (WHERE case_start >= TIMESTAMP '2026-04-25'
                         AND case_start < TIMESTAMP '2026-06-01') AS surge_cases,
       ROUND(AVG(throughput_hours), 2) AS avg_throughput_hours,
       ROUND(AVG(throughput_hours) FILTER (
           WHERE case_start >= TIMESTAMP '2026-04-25'
             AND case_start < TIMESTAMP '2026-06-01'), 2) AS surge_avg_hours,
       ROUND(AVG(throughput_hours) FILTER (
           WHERE case_start < TIMESTAMP '2026-04-25'
              OR case_start >= TIMESTAMP '2026-06-01'), 2) AS other_period_avg_hours
FROM q01_case_traces t JOIN q01_ranked_variants r USING (variant_path)
WHERE r.variant_rank IN (1, 3) GROUP BY r.variant_rank ORDER BY r.variant_rank;

-- Same activity multiset does not establish the cause of different throughput.
WITH activity_counts AS (
    SELECT r.variant_rank, e.activity, COUNT(*) AS executions,
           COUNT(DISTINCT e.case_id) AS cases_with_activity
    FROM clean_events e JOIN q01_case_traces t USING (case_id)
    JOIN q01_ranked_variants r USING (variant_path)
    WHERE r.variant_rank IN (1, 3) GROUP BY r.variant_rank, e.activity
)
SELECT * FROM activity_counts ORDER BY activity, variant_rank;

-- Complete recorded activity order for each of the top three DuckDB variants.
-- A representative case is sufficient because a variant has an identical trace.
WITH representatives AS (
    SELECT r.variant_rank, MIN(t.case_id) AS representative_case_id
    FROM q01_case_traces t JOIN q01_ranked_variants r USING (variant_path)
    WHERE r.variant_rank <= 3 GROUP BY r.variant_rank
)
SELECT r.variant_rank, r.representative_case_id,
       ROW_NUMBER() OVER (PARTITION BY r.variant_rank
           ORDER BY TRY_CAST(e.timestamp AS TIMESTAMP), e.event_id) AS activity_position,
       e.activity
FROM representatives r JOIN clean_events e ON e.case_id = r.representative_case_id
ORDER BY r.variant_rank, activity_position;
