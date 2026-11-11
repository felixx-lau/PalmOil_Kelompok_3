# Analisis Q09 Prescriptive
## Milling Capacity Investment

Tambahan kapasitas 15% tidak otomatis menghasilkan tambahan pasokan atau penjualan.

**Revisi 11 November 2026.** CSV telah dibangun ulang melalui `00_import.sql`, `02_cleaning.sql`, `02b_patch_clean.sql`, validasi, dan ekspor ulang. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Seluruh query Q01–Q10 dihitung ulang dari rilis yang sama. Dataset sintetis; timestamp UTC. Satu event remittance dikarantina, sehingga satu dependensi penutupan lot memiliki pengecualian terdokumentasi.

### 01 Evidence and Data Source

Data: `01_DATA/cleaned/celonis_event_log_clean.csv`. Model bersama: [06_scenario_model.sql](../../02_SQL/06_scenario_model.sql), [query Q09](../../02_SQL/queries_by_question/Q09.sql), dan [hasil skenario](../../05_FINANCIAL/scenario_comparison.csv). Grafik SQL dibuat sendiri, bukan ekspor Celonis. Kurs acuan tugas 1 MYR = 4.384,87 IDR; dipakai sebagai input konversi, tanpa verifikasi web baru.

| Skenario | Revenue tambahan MYR | Savings MYR | Biaya proses tambahan MYR | CAPEX MYR | OPEX 24 bulan MYR | Net benefit MYR | Net benefit IDR |
|---|---|---|---|---|---|---|---|
| Q09_CAPEX_FIXED | 0,00 | 0,00 | 0,00 | 110.000,00 | 30.000,00 | -140.000,00 | -613.881.800,00 |
| Q09_CAPEX_GROWTH | 1.061.169,25 | 0,00 | 825.413,01 | 110.000,00 | 30.000,00 | 95.756,24 | 419.878.664,09 |

### 02 Descriptive Finding

Sterilisasi mencatat 189 eksekusi, rata-rata proses 81,20 menit dan waiting 12,21 menit. Lonjakan waiting terkonsentrasi 8–9 Mei; data tidak membuktikan kapasitas kronis kurang.

### 03 Diagnostic Reasoning

Jika upgrade meningkatkan laju layanan 15%, waktu proses hipotetis menjadi 81,20/1,15 ≈ 70,61 menit. Jika yang bertambah adalah unit paralel, siklus individual tidak otomatis turun. Tidak ada model antrean yang membuktikan waiting menjadi 2,8 atau 8,5 menit.

### 04 Business and Financial Implication

Demand tetap menghasilkan net benefit −MYR 140.000,00. Skenario growth menggunakan 28,35 lot ekuivalen tambahan (189 × 15%), total 217,35; revenue dan biaya per lot dihitung dari benchmark processed, termasuk crop untuk lot baru. Net benefit growth MYR 95.756,24 setelah CAPEX 110.000 dan OPEX dua tahun 30.000. Ini bukan tambahan revenue bersih tanpa biaya.

### 05 As Is No Action and To Be

As-Is adalah baseline observed revenue MYR 7.074.461,68, biaya MYR 6.216.045,66, dan kontribusi MYR 858.416,02. No-Action adalah pengulangan cohort dengan volume/biaya sama, bukan ramalan. To-Be memakai parameter di tabel; semua OPEX tahunan dikalikan dua agar sesuai horizon 24 bulan. Seluruh hasil merupakan skenario bersyarat.

### 06 Recommendation Risk and Assumptions

Tunda CAPEX pada demand tetap. Growth hanya dapat dipertimbangkan bila pasokan baru, demand, kapasitas stasiun lain, mutu dan biaya marjinal dibuktikan. Benchmark biaya rata-rata adalah proxy; biaya pembukaan kebun dan pembiayaan belum dimodelkan.

Efektivitas, avoidable share, harga, kapasitas, dan hubungan mutu merupakan asumsi yang perlu divalidasi. Angka dataset sintetis tidak membuktikan hasil operasional lapangan.

### 07 Evidence File Paths and SQL References

- [Hasil query Q09](../../02_SQL/results/Q09_01.csv)
- [Model bersama](../../02_SQL/06_scenario_model.sql)
- [Perbandingan seluruh skenario](../../05_FINANCIAL/scenario_comparison.csv)
- [Sensitivitas](../../05_FINANCIAL/sensitivity.csv)
- [Asal bukti visual](../../03_CELONIS_EVIDENCE/README.md)

[Manifest asal bukti visual](../../03_CELONIS_EVIDENCE/README.md). Grafik mandiri terbaru: [Q09 SQL](../../03_CELONIS_EVIDENCE/Q09/Q09_scenario_sql.png).
