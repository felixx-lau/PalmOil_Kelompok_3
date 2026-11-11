"""Regression tests for evidence-based repairs and release gates."""
from pathlib import Path
import os
import unittest
import duckdb

ROOT=Path(__file__).resolve().parents[1]

class CleaningRegression(unittest.TestCase):
    def setUp(self):
        os.chdir(ROOT)
        self.con=duckdb.connect()
        for script in ('00_import.sql','02_cleaning.sql','02b_patch_clean.sql'):
            self.con.execute((ROOT/'02_SQL'/script).read_text())
    def tearDown(self): self.con.close()
    def validation(self):
        self.con.execute((ROOT/'02_SQL/03_validation.sql').read_text())
        return dict(self.con.execute('SELECT * FROM validation_checks').fetchall())
    def test_release_has_no_unacknowledged_failures(self):
        checks=self.validation()
        self.assertEqual(len(checks),26)
        self.assertTrue(all(n==0 for n in checks.values()),checks)
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM dependency_exceptions').fetchone()[0],1)
    def test_source_ready_is_preserved(self):
        row=self.con.execute("SELECT strftime(activity_ready_time,'%Y-%m-%d %H:%M:%S'), waiting_time_minutes,sla_violation FROM clean_events WHERE event_id='EVT-0004091'").fetchone()
        self.assertEqual(tuple(map(str,row)),('2026-05-08 19:03:00','278.00','True'))
    def test_missing_ids_recovered_from_unique_master_pairs(self):
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM clean_events WHERE employee_id IS NULL OR resource_id IS NULL').fetchone()[0],0)
        self.assertEqual(dict(self.con.execute('SELECT field_name, COUNT(*) FROM cleaning_patch_audit GROUP BY 1').fetchall()), {'case_type':20,'employee_id':4,'resource_id':2,'activity_ready_time':1})
    def test_quarantine_rework_and_event_conservation(self):
        self.assertEqual(self.con.execute('SELECT COUNT(*),COUNT(DISTINCT event_id),COUNT(DISTINCT case_id) FROM clean_events').fetchone(),(6179,6179,230))
        self.assertEqual(self.con.execute('SELECT event_id FROM quarantined_events').fetchone()[0],'EVT-0000623')
        self.assertEqual(self.con.execute("SELECT COUNT(*) FROM clean_events WHERE rework_flag OR activity ILIKE '%rework%'").fetchone()[0],76)
    def test_old_ready_bug_is_detected(self):
        self.con.execute("UPDATE clean_events SET activity_ready_time=activity_start_time WHERE event_id='EVT-0004091'")
        self.assertEqual(self.validation()['waiting_identity'],1)
    def test_patch_also_repairs_legacy_table(self):
        self.con.execute("UPDATE clean_events SET activity_ready_time=activity_start_time WHERE event_id='EVT-0004091'")
        self.con.execute((ROOT/'02_SQL/02b_patch_clean.sql').read_text())
        self.assertEqual(self.validation()['waiting_identity'],0)
    def test_nulls_and_missing_joins_do_not_pass_gate(self):
        self.con.execute("UPDATE clean_events SET material_cost=NULL,employee_id=NULL WHERE event_id='EVT-0004091'")
        checks=self.validation()
        self.assertGreater(checks['required_cells'],0)
        self.assertGreater(checks['employee_resource_mapping'],0)
        self.con.execute("DELETE FROM clean_events WHERE event_id='EVT-0004091'")
        self.assertEqual(self.validation()['source_event_conservation'],1)
    def test_variants_and_scenario_reconcile_after_csv_roundtrip(self):
        self.con.execute('CREATE TABLE expected AS SELECT * FROM clean_events')
        self.con.execute("CREATE OR REPLACE TABLE clean_events AS SELECT * FROM read_csv_auto('01_DATA/cleaned/celonis_event_log_clean.csv')")
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM (SELECT * FROM expected EXCEPT ALL SELECT * FROM clean_events)').fetchone()[0],0)
        sql=(ROOT/'02_SQL/queries_by_question/Q01.sql').read_text()
        statements=self.con.extract_statements(sql)
        self.con.execute(statements[0]);self.con.execute(statements[1])
        self.assertEqual([r[1] for r in self.con.fetchall()[:3]],[61,23,17])
        self.con.execute((ROOT/'02_SQL/06_scenario_model.sql').read_text())
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM scenario_comparison WHERE revenue_myr-cost_myr<>to_be_contribution_myr').fetchone()[0],0)
        self.assertEqual(str(self.con.execute("SELECT net_financial_benefit_myr FROM scenario_comparison WHERE scenario_id='Q10_COMBINED'").fetchone()[0]),'116493.56')

if __name__=='__main__': unittest.main()
