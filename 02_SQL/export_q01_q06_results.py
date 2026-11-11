"""Compatibility entry point; re-export Q01-Q10 from the released CSV."""
import os
import duckdb
from run_pipeline import ROOT, analyze
os.chdir(ROOT)
with duckdb.connect() as con:
    con.execute("CREATE TABLE clean_events AS SELECT * FROM read_csv_auto(?)", [str(ROOT/'01_DATA/cleaned/celonis_event_log_clean.csv')])
    analyze(con)
