"""Create clearly labelled, independent SQL figures. Never impersonates Celonis.
Run after: python3 02_SQL/run_pipeline.py
Requires matplotlib; outputs only *_sql.png and provenance manifests.
"""
from pathlib import Path
import csv, os, hashlib, json, textwrap
os.environ.setdefault('MPLCONFIGDIR','/private/tmp/palm_matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'03_CELONIS_EVIDENCE'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False})
def read(name): return list(csv.DictReader((ROOT/name).open()))
created=[]
def save(fig,path):
 fig.text(.5,.015,'Grafik mandiri dari DuckDB SQL | bukan ekspor Celonis | rilis 11 November 2026',ha='center',fontsize=9,color='#555555')
 fig.tight_layout(rect=(0,.05,1,1));p=OUT/path;p.parent.mkdir(exist_ok=True,parents=True)
 fig.savefig(p,dpi=180,bbox_inches='tight');plt.close(fig);created.append(p)
# Q01: trace-frequency chart and actual directly-follows edge graph.
r=read('02_SQL/results/Q01_01.csv')[:3]
f,a=plt.subplots(figsize=(8,4));a.bar(['Varian 1','Varian 2','Varian 3'],[int(x['case_volume']) for x in r],color=['#245c4b','#b76b42','#5685a4']);a.set(ylabel='Lot',title='Q01 Tiga varian terbesar menurut SQL');a.bar_label(a.containers[0]);save(f,'Q01/Q01_variants_sql.png')
events=read('01_DATA/cleaned/celonis_event_log_clean.csv');by_case={}
for e in events:by_case.setdefault(e['case_id'],[]).append(e)
edges=Counter();nodes=Counter()
for es in by_case.values():
 es.sort(key=lambda x:(x['timestamp'],x['event_id']))
 for e in es:nodes[e['activity']]+=1
 for a,b in zip(es,es[1:]):edges[a['activity'],b['activity']]+=1
with (OUT/'Q01/Q01_actual_process_edges_sql.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['from_activity','to_activity','directly_follows_count']);w.writerows((a,b,n) for (a,b),n in sorted(edges.items()))
# Matrix gives the full DFG without unreadable crossed arrows. Every nonzero
# cell is an edge; ordering uses the representative main route, then branches.
main=read('02_SQL/results/Q01_04.csv');order=[x['activity'] for x in main if x['variant_rank']=='1']
order+=sorted(set(nodes)-set(order));ids={x:i for i,x in enumerate(order)}
matrix=[[edges.get((a,b),0) for b in order] for a in order]
f,a=plt.subplots(figsize=(15,12));a.imshow(matrix,cmap='Blues',vmin=0,vmax=230)
labels=[f'{i+1:02} '+x for i,x in enumerate(order)]
a.set_yticks(range(len(order)),labels,fontsize=8);a.set_xticks(range(len(order)),[f'{i+1:02}' for i in range(len(order))],fontsize=8)
a.set(xlabel='Aktivitas penyelesaian berikutnya (nomor mengikuti label baris)',ylabel='Aktivitas asal',title='Q01 Actual Process Map SQL dalam matriks hubungan langsung\nAngka = frekuensi panah pada urutan timestamp, event_id; bukan dependensi fisik')
for (src,dst),n in edges.items():a.text(ids[dst],ids[src],str(n),ha='center',va='center',fontsize=6,color='white' if n>100 else 'black')
save(f,'Q01/Q01_actual_process_map_sql.png')
r=read('02_SQL/results/Q02_01.csv');f,a=plt.subplots(figsize=(8,4));a.bar([x['outcome'] for x in r],[int(x['lots']) for x in r],color=['#245c4b','#b76b42','#78909c']);a.set(ylabel='Lot',title='Q02 Outcome lot');a.bar_label(a.containers[0]);save(f,'Q02/Q02_outcomes_sql.png')
r=read('02_SQL/results/Q03_01.csv');f,a=plt.subplots(figsize=(9,4));a.barh([x['process_stage'] for x in r],[float(x['total_waiting_hours']) for x in r],color='#245c4b');a.invert_yaxis();a.set(xlabel='Jumlah waiting event (jam)',title='Q03 Waiting per tahap, terkonsentrasi Mei 2026');a.bar_label(a.containers[0],fmt='%.2f');save(f,'Q03/Q03_stage_waiting_sql.png')
r=read('02_SQL/results/Q04_01.csv');f,a=plt.subplots(figsize=(8,4));a.bar(['<2 jam','2–3 jam','>3–4 jam','>4 jam'],[float(x['rejection_rate_pct']) for x in r],color='#b76b42');a.set(ylabel='Rejection rate (%)',title='Q04 Hubungan tidak monoton; target 3 jam / 8% adalah pilot');a.bar_label(a.containers[0],fmt='%.2f');save(f,'Q04/Q04_buckets_sql.png')
r=[x for x in read('02_SQL/results/Q05_04.csv') if x['facility_id'] in ['FAC-029','FAC-030','FAC-031'] and x['processing_date']=='2026-05-09'];f,a=plt.subplots(figsize=(8,4));a.bar([x['facility_id'] for x in r],[float(x['calendar_load_pct']) for x in r],color='#5685a4');a.set(ylabel='Beban terhadap 24 jam (%)',title='Q05 Beban kalender sterilizer, 9 Mei 2026',ylim=(0,100));a.bar_label(a.containers[0],fmt='%.2f');save(f,'Q05/Q05_daily_load_sql.png')
r=read('02_SQL/results/Q06_01.csv');f,a=plt.subplots(figsize=(9,4));a.barh([x['activity'] for x in r],[float(x['total_rework_cost_myr']) for x in r],color='#b76b42');a.invert_yaxis();a.set(xlabel='Biaya tercatat MYR',title='Q06 Rework sah tetap dipertahankan');save(f,'Q06/Q06_rework_sql.png')
s=read('05_FINANCIAL/scenario_comparison.csv')
for n,keys in [(7,['Q07_SCHED']),(8,['Q08_GRADE']),(9,['Q09_CAPEX_FIXED','Q09_CAPEX_GROWTH']),(10,['Q08_GRADE','Q10_QUALITY','Q07_SCHED','Q09_CAPEX_FIXED'])]:
 r=[x for key in keys for x in s if x['scenario_id']==key];f,a=plt.subplots(figsize=(9,4));a.barh([x['scenario_id'] for x in r],[float(x['net_financial_benefit_myr']) for x in r],color=['#245c4b' if float(x['net_financial_benefit_myr'])>0 else '#b76b42' for x in r]);a.invert_yaxis();a.axvline(0,color='#777',lw=.7);a.set(xlabel='Net benefit MYR setelah CAPEX + OPEX 24 bulan',title=f'Q{n:02} Skenario bersyarat, bukan realisasi');save(f,f'Q{n:02}/Q{n:02}_scenario_sql.png')
manifest=[]
for p in sorted(OUT.rglob('*.png')):
 generated=p in created
 manifest.append({'path':str(p.relative_to(ROOT)),'kind':'independent_sql_graphic' if generated else 'preexisting_ui_capture_unverified_origin','source':'generate_evidence.py and released SQL results' if generated else 'provided in project before this revision; originating app/session not independently verified','sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'evidence_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(OUT/'README.md').write_text('''# Asal bukti visual Palm Oil

Rilis 11 November 2026. Angka utama berasal dari DuckDB, bukan hasil pembacaan gambar. `evidence_manifest.json` mencatat asal dan hash setiap PNG.

File `*_sql.png` dibuat sendiri oleh `generate_evidence.py` dari hasil query/CSV rilis terbaru. Setiap gambar menyebut bahwa ia bukan ekspor Celonis. Actual Process Map SQL disajikan sebagai matriks adjacency: setiap sel bernilai adalah panah directly-follows pada urutan completion timestamp, event_id. Ini mempertahankan semua hubungan tanpa menganggapnya sebagai dependensi fisik. Daftar edge lengkap ada di Q01/Q01_actual_process_edges_sql.csv.

PNG lama berupa tangkapan layar antarmuka yang disediakan bersama proyek. Nama file lama tidak sama dengan target savefig script generator versi sebelumnya. Pemeriksaan visual menunjukkan tampilan tabel/peta aplikasi; revisi ini tidak membuktikan asal aplikasi, workspace, filter, atau konfigurasi sorting secara independen. Tidak ada screenshot Celonis baru yang dibuat atau diklaim terverifikasi dalam revisi ini. Jangan melabeli semua PNG lama sebagai keluaran matplotlib atau semua PNG sebagai ekspor Celonis terverifikasi.

Daftar varian pada tangkapan layar lama adalah 62/23/17; SQL rilis adalah 61/23/17. Angka finansial/waktu selalu mengikuti grouping SQL. Penyebab selisih satu case belum direkonsiliasi. Peta lama Q01_process_map_overview_part1/part2 ditautkan di jawaban sebagai ilustrasi antarmuka lama, dengan batas asal bukti ini.

Jika rubric mewajibkan bukti Celonis terverifikasi, impor CSV rilis baru pada workspace yang digunakan kelompok dan ambil screenshot beserta nama analisis/filter/sorting. Grafik SQL tidak menggantikan persyaratan khusus penggunaan aplikasi tersebut.
''')
print(f'Created {len(created)} independent SQL graphics; preserved prior UI captures.')
