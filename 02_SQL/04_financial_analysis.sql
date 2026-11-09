-- ====================================================================
-- PALM OIL HARVEST-TO-CPO PROCESS MINING PROJECT
-- Group: 24SI1 • GROUP 03
-- Script: 04_financial_analysis.sql
-- Purpose: Financial analysis, validation, baseline, rework, what-if, and IDR FX conversion.
-- ====================================================================

-- 01 | Memuat file cleaned dan menyiapkan tipe data
CREATE OR REPLACE TABLE clean_events AS
SELECT *
FROM read_csv(
    '01_DATA/cleaned/celonis_event_log_clean.csv',
    header = true
);

CREATE OR REPLACE VIEW financial_events AS
SELECT
    event_id,
    case_id,
    activity,
    currency,
    TRY_CAST(activity_total_cost AS DECIMAL(18,2)) AS activity_cost,
    TRY_CAST(revenue_allocated AS DECIMAL(18,2)) AS revenue,
    TRY_CAST(profit_contribution AS DECIMAL(18,2)) AS recorded_contribution,
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true','1','yes','y') AS is_rework,
    TRY_CAST(waiting_time_minutes AS DOUBLE) AS waiting_minutes
FROM clean_events;

-- Eksplorasi sampel 8 baris
SELECT * FROM financial_events LIMIT 8;

-- 02 | Financial validation sebelum agregasi
SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) FILTER (
        WHERE case_id IS NULL OR event_id IS NULL
    ) AS missing_identifiers,
    COUNT(*) FILTER (
        WHERE activity_cost IS NULL
           OR revenue IS NULL
           OR recorded_contribution IS NULL
    ) AS invalid_financial_rows,
    COUNT(*) FILTER (
        WHERE ABS(recorded_contribution - (revenue - activity_cost)) > 0.01
    ) AS inconsistent_contribution_rows
FROM financial_events;

-- 03 | Revenue, cost, contribution per case dan perusahaan
CREATE OR REPLACE VIEW case_financials AS
SELECT
    case_id,
    COUNT(*) AS total_events,
    ROUND(SUM(revenue),2) AS total_revenue,
    ROUND(SUM(activity_cost),2) AS total_cost,
    ROUND(SUM(revenue) - SUM(activity_cost),2) AS profit_contribution
FROM financial_events
GROUP BY case_id;

-- 10 case dengan contribution terendah (termasuk rejected dan cancelled)
SELECT * FROM case_financials
ORDER BY profit_contribution ASC 
LIMIT 10;

-- Financial baseline untuk seluruh 230 case
SELECT
    COUNT(*) AS total_cases,
    SUM(total_events) AS total_events,
    ROUND(SUM(total_revenue),2) AS revenue,
    ROUND(SUM(total_cost),2) AS operational_cost,
    ROUND(SUM(profit_contribution),2) AS profit_contribution,
    ROUND(SUM(total_cost) / NULLIF(COUNT(*),0),2) AS cost_per_case
FROM case_financials;

-- 04 | High-cost activities dan biaya Rework terkait
-- Kegiatan dengan aggregate cost terbesar
SELECT
    activity,
    COUNT(*) AS executions,
    ROUND(SUM(activity_cost),2) AS total_cost,
    ROUND(AVG(activity_cost),2) AS avg_cost
FROM financial_events
GROUP BY activity
ORDER BY total_cost DESC 
LIMIT 10;

-- Screening rework-related cost
SELECT
    case_id,
    ROUND(SUM(activity_cost),2) AS rework_related_cost
FROM financial_events
WHERE is_rework OR activity ILIKE '%rework%'
GROUP BY case_id
ORDER BY rework_related_cost DESC 
LIMIT 10;

-- 05 | What-if Analysis: As-Is, No-Action, To-Be
CREATE OR REPLACE VIEW financial_scenario AS
WITH baseline AS (
    SELECT
        SUM(revenue) AS revenue,
        SUM(activity_cost) AS cost,
        SUM(CASE WHEN is_rework OR activity ILIKE '%rework%' THEN activity_cost ELSE 0 END) AS rework_related_cost
    FROM financial_events
),
assumptions AS (
    SELECT
        0.25 AS rework_reduction_rate,
        0.80 AS avoidable_share,
        100.00 AS implementation_cost,
        20.00 AS additional_operating_cost,
        0.00 AS incremental_revenue
),
calculation AS (
    SELECT
        b.revenue - b.cost AS as_is_contribution,
        b.rework_related_cost,
        b.rework_related_cost * a.avoidable_share * a.rework_reduction_rate AS avoidable_cost_savings,
        a.incremental_revenue,
        a.implementation_cost,
        a.additional_operating_cost
    FROM baseline b 
    CROSS JOIN assumptions a
)
SELECT 
    *,
    avoidable_cost_savings + incremental_revenue - implementation_cost - additional_operating_cost AS net_financial_benefit,
    as_is_contribution + avoidable_cost_savings + incremental_revenue - implementation_cost - additional_operating_cost AS to_be_contribution
FROM calculation;

SELECT * FROM financial_scenario;

-- 06 | Konversi mata uang ke IDR dengan kurs BI 13 Oktober 2026
CREATE OR REPLACE VIEW fx_ref AS
SELECT
    currency,
    TRY_CAST(reference_idr_per_1_unit AS DECIMAL(20,6)) AS idr_per_unit
FROM read_csv(
    '05_FINANCIAL/exchange_rate.csv',
    header = true,
    all_varchar = true
)
WHERE reference_date = '2026-10-13'
  AND currency = 'MYR';

SELECT
    'MYR' AS original_currency,
    ROUND(s.as_is_contribution,2) AS as_is_original,
    ROUND(s.as_is_contribution * fx.idr_per_unit,2) AS as_is_idr,
    ROUND(s.net_financial_benefit,2) AS net_benefit_original,
    ROUND(s.net_financial_benefit * fx.idr_per_unit,2) AS net_benefit_idr,
    ROUND(s.to_be_contribution,2) AS to_be_original,
    ROUND(s.to_be_contribution * fx.idr_per_unit,2) AS to_be_idr
FROM financial_scenario s
CROSS JOIN fx_ref fx;
