"""Reproduce Q01–Q06 using DuckDB and export each SELECT to CSV.

Run from any directory: python3 02_SQL/export_q01_q06_results.py
Requires: duckdb. The source CSV is read without modifying it.
"""
from pathlib import Path
import csv
import duckdb

root = Path(__file__).resolve().parent.parent
output = root / '02_SQL/results'
output.mkdir(exist_ok=True)
with duckdb.connect() as con:
    con.execute('CREATE TABLE clean_events AS SELECT * FROM read_csv_auto(?)',
                [str(root / '01_DATA/cleaned/celonis_event_log_clean.csv')])
    print(f'DuckDB {duckdb.__version__}: ' + str(con.execute(
        'SELECT COUNT(*), COUNT(DISTINCT case_id) FROM clean_events').fetchone()))
    for number in range(1, 7):
        question = f'Q{number:02}'
        index = 0
        script = (root / f'02_SQL/queries_by_question/{question}.sql').read_text()
        for statement in con.extract_statements(script):
            con.execute(statement)
            if statement.type == duckdb.StatementType.SELECT:
                index += 1
                with (output / f'{question}_{index:02}.csv').open('w', newline='') as stream:
                    writer = csv.writer(stream)
                    writer.writerow([column[0] for column in con.description])
                    writer.writerows(con.fetchall())
        print(f'{question}: exported {index} result sets')
