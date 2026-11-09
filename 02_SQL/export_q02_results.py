"""Run Q02 against the current clean CSV and export every SELECT result.
Usage from the project root: python3 02_SQL/export_q02_results.py
Requires the duckdb Python package.
"""
from pathlib import Path
import csv
import duckdb

root = Path(__file__).resolve().parent.parent
con = duckdb.connect()
con.execute(
    'CREATE TABLE clean_events AS SELECT * FROM read_csv_auto(?)',
    [str(root / '01_DATA/cleaned/celonis_event_log_clean.csv')],
)
output = root / '02_SQL/results'
output.mkdir(exist_ok=True)
for question in ('Q02',):
    index = 0
    script = (root / f'02_SQL/queries_by_question/{question}.sql').read_text()
    for statement in con.extract_statements(script):
        con.execute(statement)
        if statement.type == duckdb.StatementType.SELECT:
            index += 1
            target = output / f'{question}_{index:02}.csv'
            with target.open('w', newline='') as stream:
                writer = csv.writer(stream)
                writer.writerow([column[0] for column in con.description])
                writer.writerows(con.fetchall())
    print(f'{question}: exported {index} result sets')
con.close()
