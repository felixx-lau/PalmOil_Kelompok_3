"""Rebuild, validate, export and analyze the synthetic dataset. Never edits raw data.

Run: python3 02_SQL/run_pipeline.py (requires duckdb).
Validation failures stop publication of the cleaned CSV.
"""
from pathlib import Path
import csv
import hashlib
import json
import os
import duckdb

ROOT = Path(__file__).resolve().parent.parent


def export_table(con, query, path):
    con.execute(query)
    with path.open('w', newline='', encoding='utf-8') as stream:
        writer = csv.writer(stream)
        writer.writerow([col[0] for col in con.description])
        writer.writerows(con.fetchall())


def analyze(con):
    con.execute((ROOT / '02_SQL/06_scenario_model.sql').read_text())
    output = ROOT / '02_SQL/results'
    output.mkdir(exist_ok=True)
    for number in range(1, 11):
        question, index = f'Q{number:02}', 0
        for statement in con.extract_statements((ROOT / f'02_SQL/queries_by_question/{question}.sql').read_text()):
            con.execute(statement)
            if statement.type == duckdb.StatementType.SELECT:
                index += 1
                with (output / f'{question}_{index:02}.csv').open('w', newline='', encoding='utf-8') as stream:
                    writer = csv.writer(stream)
                    writer.writerow([column[0] for column in con.description])
                    writer.writerows(con.fetchall())
        print(f'{question}: {index} result sets')


def main():
    os.chdir(ROOT)
    validation = ROOT / '01_DATA/validation'
    with duckdb.connect() as con:
        for script in ('00_import.sql', '02_cleaning.sql', '02b_patch_clean.sql', '03_validation.sql'):
            con.execute((ROOT / '02_SQL' / script).read_text())
        export_table(con, 'SELECT * FROM validation_checks ORDER BY check_name', validation / 'validation_results.csv')
        failures = con.execute('SELECT * FROM validation_checks WHERE failures <> 0').fetchall()
        if failures:
            raise RuntimeError(f'Cleaning validation failed: {failures}')
        for table in ('cleaning_patch_audit', 'quarantined_events', 'dependency_exceptions'):
            export_table(con, f'SELECT * FROM {table}', validation / f'{table}.csv')
        target = '01_DATA/cleaned/celonis_event_log_clean.csv'
        temporary = '01_DATA/cleaned/.verified_event_log.csv'
        script = (ROOT / '02_SQL/05_celonis_export.sql').read_text().replace(target, temporary)
        try:
            con.execute(script)
            con.execute('CREATE TABLE roundtrip AS SELECT * FROM read_csv_auto(?)', [temporary])
            diff = con.execute('SELECT COUNT(*) FROM ((SELECT * FROM clean_events EXCEPT ALL SELECT * FROM roundtrip) UNION ALL (SELECT * FROM roundtrip EXCEPT ALL SELECT * FROM clean_events))').fetchone()[0]
            if diff:
                raise RuntimeError(f'CSV roundtrip mismatch: {diff}')
            # Compare with previously submitted CSV without changing the baseline.
            con.execute('CREATE TABLE previous AS SELECT * FROM read_csv_auto(?)', [target])
            changes = con.execute('SELECT COUNT(*) FROM (SELECT * FROM clean_events EXCEPT SELECT * FROM previous)').fetchone()[0]
            con.execute('CREATE TABLE old_events AS SELECT * FROM previous')
            summary = []
            for table in ('old_events', 'clean_events'):
                summary.append((table,) + con.execute(f'SELECT COUNT(*), COUNT(DISTINCT case_id), SUM(waiting_time_minutes), SUM(activity_duration_minutes), SUM(sla_violation::INT), SUM(activity_total_cost), SUM(revenue_allocated), SUM(profit_contribution) FROM {table}').fetchone())
            with (validation / ('before_after_summary.csv' if not (validation / 'before_after_summary.csv').exists() else 'latest_run_summary.csv')).open('w', newline='') as stream:
                writer = csv.writer(stream)
                writer.writerow(['dataset','events','cases','waiting_minutes','processing_minutes','sla_violations','cost_myr','revenue_myr','contribution_myr'])
                writer.writerows(summary)
            os.replace(ROOT / temporary, ROOT / target)
        finally:
            (ROOT / temporary).unlink(missing_ok=True)
        analyze(con)
        export_table(con, 'SELECT * FROM scenario_comparison ORDER BY scenario_id', ROOT / '05_FINANCIAL/scenario_comparison.csv')
        export_table(con, 'SELECT * FROM model_sensitivity ORDER BY initiative, effectiveness', ROOT / '05_FINANCIAL/sensitivity.csv')
        manifest = {
            'release_date': '2026-11-11', 'duckdb_version': duckdb.__version__,
            'validation_checks_passed': con.execute('SELECT COUNT(*) FROM validation_checks').fetchone()[0],
            'patch_event_count_vs_pre_revision_csv': con.execute('SELECT COUNT(DISTINCT event_id) FROM cleaning_patch_audit').fetchone()[0],
            'changed_event_rows_vs_previous_csv': changes,
            'quarantine_count': con.execute('SELECT COUNT(*) FROM quarantined_events').fetchone()[0],
            'dependency_exceptions': con.execute('SELECT COUNT(*) FROM dependency_exceptions').fetchone()[0],
            'csv_roundtrip_differences': diff,
            'sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((ROOT/'01_DATA/raw').glob('*.csv')) + [ROOT/target]},
        }
        (validation / 'release_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        print(f"Released: {manifest['validation_checks_passed']} checks passed; {changes} changed event rows; raw files preserved.")


if __name__ == '__main__':
    main()
