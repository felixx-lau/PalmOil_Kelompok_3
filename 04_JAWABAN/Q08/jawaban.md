# Analisis Q08 Prescriptive
## FFB Grading Improvement

Penurunan reject 15% relatif adalah asumsi pencegahan kerusakan yang memungkinkan buah diproses, bukan sekadar menolak buah lebih awal.

**Revisi 11 November 2026.** CSV telah dibangun ulang melalui `00_import.sql`, `02_cleaning.sql`, `02b_patch_clean.sql`, validasi, dan ekspor ulang. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Seluruh query Q01–Q10 dihitung ulang dari rilis yang sama. Dataset sintetis; timestamp UTC. Satu event remittance dikarantina, sehingga satu dependensi penutupan lot memiliki pengecualian terdokumentasi.

### 01 Evidence and Data Source

Data: `01_DATA/cleaned/celonis_event_log_clean.csv`. Model bersama: [06_scenario_model.sql](../../02_SQL/06_scenario_model.sql), [query Q08](../../02_SQL/queries_by_question/Q08.sql), dan [hasil skenario](../../05_FINANCIAL/scenario_comparison.csv). Grafik SQL dibuat sendiri, bukan ekspor Celonis. Kurs acuan tugas 1 MYR = 4.384,87 IDR; dipakai sebagai input konversi, tanpa verifikasi web baru.

| Skenario | Revenue tambahan MYR | Savings MYR | Biaya proses tambahan MYR | CAPEX MYR | OPEX 24 bulan MYR | Net benefit MYR | Net benefit IDR |
|---|---|---|---|---|---|---|---|
| Q08_GRADE | 162.824,91 | 0,00 | 24.116,89 | 20.000,00 | 10.000,00 | 108.708,02 | 476.670.535,66 |

### 02 Descriptive Finding

Baseline 29 reject dari 218 lot dipanen (13,30%). Pengurangan 15% relatif menghasilkan 4,35 lot ekuivalen terselamatkan, 24,65 reject tersisa, dan rejection rate 11,31%. Pecahan lot adalah volume harapan.

### 03 Diagnostic Reasoning

Revenue benchmark processed = MYR 37.431,01417989418/lot; biaya proses pemulihan proxy = MYR 5.544,11291005291/lot. Proxy hanya mencakup aktivitas setelah penerimaan yang belum terjadi pada reject: receipt accepted, ramp, milling, storage, dispatch, dan finance. Biaya crop, transport, timbang, inspeksi, penolakan dan penutupan yang sudah tercatat tidak dikembalikan atau dibebankan dua kali. Gunakan presisi penuh lalu bulatkan komponen skenario ke sen.

### 04 Business and Financial Implication

Revenue tambahan MYR 162.824,91 dikurangi biaya proses MYR 24.116,89, CAPEX 20.000 dan OPEX dua tahun 10.000 menghasilkan net benefit MYR 108.708,02. Ini model manfaat setelah investasi, bukan bukti pemulihan kas sunk cost.

### 05 As Is No Action and To Be

As-Is adalah baseline observed revenue MYR 7.074.461,68, biaya MYR 6.216.045,66, dan kontribusi MYR 858.416,02. No-Action adalah pengulangan cohort dengan volume/biaya sama, bukan ramalan. To-Be memakai parameter di tabel; semua OPEX tahunan dikalikan dua agar sesuai horizon 24 bulan. Seluruh hasil merupakan skenario bersyarat.

### 06 Recommendation Risk and Assumptions

Prioritaskan pilot pencegahan reject. Alat, biaya, kemampuan menyelamatkan buah, kapasitas pabrik, mutu jual, dan demand perlu diuji; harga alat adalah asumsi tugas, bukan quotation vendor.

Efektivitas, avoidable share, harga, kapasitas, dan hubungan mutu merupakan asumsi yang perlu divalidasi. Angka dataset sintetis tidak membuktikan hasil operasional lapangan.

### 07 Evidence File Paths and SQL References

- [Hasil query Q08](../../02_SQL/results/Q08_01.csv)
- [Model bersama](../../02_SQL/06_scenario_model.sql)
- [Perbandingan seluruh skenario](../../05_FINANCIAL/scenario_comparison.csv)
- [Sensitivitas](../../05_FINANCIAL/sensitivity.csv)
- [Asal bukti visual](../../03_CELONIS_EVIDENCE/README.md)

[Manifest asal bukti visual](../../03_CELONIS_EVIDENCE/README.md). Grafik mandiri terbaru: [Q08 SQL](../../03_CELONIS_EVIDENCE/Q08/Q08_scenario_sql.png).
