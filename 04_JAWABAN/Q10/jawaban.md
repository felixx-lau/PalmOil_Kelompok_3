# Analisis Q10 Prescriptive
## Estate to Mill Business Case

Prioritas berdasarkan net benefit bersyarat pada horizon 24 bulan; keberhasilan perlu dibuktikan melalui pilot.

**Revisi 11 November 2026.** CSV telah dibangun ulang melalui `00_import.sql`, `02_cleaning.sql`, `02b_patch_clean.sql`, validasi, dan ekspor ulang. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Seluruh query Q01–Q10 dihitung ulang dari rilis yang sama. Dataset sintetis; timestamp UTC. Satu event remittance dikarantina, sehingga satu dependensi penutupan lot memiliki pengecualian terdokumentasi.

### 01 Evidence and Data Source

Data: `01_DATA/cleaned/celonis_event_log_clean.csv`. Model bersama: [06_scenario_model.sql](../../02_SQL/06_scenario_model.sql), [query Q10](../../02_SQL/queries_by_question/Q10.sql), dan [hasil skenario](../../05_FINANCIAL/scenario_comparison.csv). Grafik SQL dibuat sendiri, bukan ekspor Celonis. Kurs acuan tugas 1 MYR = 4.384,87 IDR; dipakai sebagai input konversi, tanpa verifikasi web baru.

| Skenario | Revenue tambahan MYR | Savings MYR | Biaya proses tambahan MYR | CAPEX MYR | OPEX 24 bulan MYR | Net benefit MYR | Net benefit IDR |
|---|---|---|---|---|---|---|---|
| Q08_GRADE | 162.824,91 | 0,00 | 24.116,89 | 20.000,00 | 10.000,00 | 108.708,02 | 476.670.535,66 |
| Q10_QUALITY | 10.474,54 | 8.311,00 | 0,00 | 8.000,00 | 3.000,00 | 7.785,54 | 34.138.580,78 |
| Q07_SCHED | 0,00 | 917,19 | 0,00 | 6.000,00 | 2.400,00 | -7.482,81 | -32.811.149,08 |
| Q09_CAPEX_FIXED | 0,00 | 0,00 | 0,00 | 110.000,00 | 30.000,00 | -140.000,00 | -613.881.800,00 |
| Q10_COMBINED | 173.299,45 | 8.311,00 | 24.116,89 | 28.000,00 | 13.000,00 | 116.493,56 | 510.809.116,44 |

### 02 Descriptive Finding

Ranking program mandiri: Q08 MYR 108.708,02; pencegahan mutu CPO MYR 7.785,54; Q07 −MYR 7.482,81; Q09 demand tetap −MYR 140.000,00. Skenario growth Q09 terpisah karena membutuhkan tambahan pasokan dan demand.

### 03 Diagnostic Reasoning

Program mutu hanya memakai quality rework + retest CPO MYR 20.777,51 × 40% = MYR 8.311,00; field grading tidak dihitung agar tidak tumpang tindih dengan Q08. Allowance MYR 20.949,08 × 50% = MYR 10.474,54. Retest wajib dipertahankan; savings diasumsikan berasal dari pencegahan kegagalan, bukan melewati uji. Manfaat pada lot baru Q08 tidak diberi tambahan savings mutu agar tidak dihitung ganda.

### 04 Business and Financial Implication

Gabungan menambah revenue MYR 173.299,45. Biaya bersih bertambah MYR 56.805,89 = proses 24.116,89 + CAPEX 28.000 + OPEX 13.000 − savings 8.311. Net benefit MYR 116.493,56 dan nilai setelah investasi MYR 974.909,58. Revenue MYR 7.247.761,13 − biaya termasuk investasi MYR 6.272.851,55 = MYR 974.909,58. CAPEX dibebankan sekali untuk evaluasi investasi, bukan dicampur sebagai laba akuntansi tanpa depresiasi.

### 05 As Is No Action and To Be

As-Is adalah baseline observed revenue MYR 7.074.461,68, biaya MYR 6.216.045,66, dan kontribusi MYR 858.416,02. No-Action adalah pengulangan cohort dengan volume/biaya sama, bukan ramalan. To-Be memakai parameter di tabel; semua OPEX tahunan dikalikan dua agar sesuai horizon 24 bulan. Seluruh hasil merupakan skenario bersyarat.

### 06 Recommendation Risk and Assumptions

Jalankan pilot Q08 dan mutu CPO secara bertahap, dengan baseline serta kelompok pembanding. Tanpa reduksi allowance, program mutu negatif MYR 2.689; perlu penurunan allowance sekitar 12,84% untuk impas pada savings rework 40%. Sensitivitas Q08 tersedia pada reduksi reject 0–20%. Payback belum ditentukan karena jadwal arus kas tidak tersedia.

Efektivitas, avoidable share, harga, kapasitas, dan hubungan mutu merupakan asumsi yang perlu divalidasi. Angka dataset sintetis tidak membuktikan hasil operasional lapangan.

### 07 Evidence File Paths and SQL References

- [Hasil query Q10](../../02_SQL/results/Q10_01.csv)
- [Model bersama](../../02_SQL/06_scenario_model.sql)
- [Perbandingan seluruh skenario](../../05_FINANCIAL/scenario_comparison.csv)
- [Sensitivitas](../../05_FINANCIAL/sensitivity.csv)
- [Asal bukti visual](../../03_CELONIS_EVIDENCE/README.md)

[Manifest asal bukti visual](../../03_CELONIS_EVIDENCE/README.md). Grafik mandiri terbaru: [Q10 SQL](../../03_CELONIS_EVIDENCE/Q10/Q10_scenario_sql.png).
