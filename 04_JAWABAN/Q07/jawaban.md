# Analisis Q07 Prescriptive
## FFB Transport Scheduling

Penurunan waiting 20% merupakan asumsi pilot; penghematan waktu belum diimplementasikan.

**Revisi 11 November 2026.** CSV telah dibangun ulang melalui `00_import.sql`, `02_cleaning.sql`, `02b_patch_clean.sql`, validasi, dan ekspor ulang. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Seluruh query Q01–Q10 dihitung ulang dari rilis yang sama. Dataset sintetis; timestamp UTC. Satu event remittance dikarantina, sehingga satu dependensi penutupan lot memiliki pengecualian terdokumentasi.

### 01 Evidence and Data Source

Data: `01_DATA/cleaned/celonis_event_log_clean.csv`. Model bersama: [06_scenario_model.sql](../../02_SQL/06_scenario_model.sql), [query Q07](../../02_SQL/queries_by_question/Q07.sql), dan [hasil skenario](../../05_FINANCIAL/scenario_comparison.csv). Grafik SQL dibuat sendiri, bukan ekspor Celonis. Kurs acuan tugas 1 MYR = 4.384,87 IDR; dipakai sebagai input konversi, tanpa verifikasi web baru.

| Skenario | Revenue tambahan MYR | Savings MYR | Biaya proses tambahan MYR | CAPEX MYR | OPEX 24 bulan MYR | Net benefit MYR | Net benefit IDR |
|---|---|---|---|---|---|---|---|
| Q07_SCHED | 0,00 | 917,19 | 0,00 | 6.000,00 | 2.400,00 | -7.482,81 | -32.811.149,08 |

### 02 Descriptive Finding

Transport mencatat 7.763 menit atau 129,38 jam waiting pada 654 event dalam 218 lot. Rata-rata 11,87 menit per event berbeda dari 35,61 menit per lot. Target 20% setara 25,88 jam, bukan hasil penghematan aktual.

### 03 Diagnostic Reasoning

Savings = equipment transport MYR 38.216,18 × avoidable share 12% × reduksi 20% = MYR 917,19. Porsi avoidable adalah asumsi; dataset tidak membuktikan struktur gaji tetap atau konsumsi BBM idle. Biaya transport keseluruhan bukan basis savings 12%.

### 04 Business and Financial Implication

Net benefit negatif MYR 7.482,81 setelah CAPEX 6.000 dan OPEX 1.200/tahun selama dua tahun. Dampak kualitas, revenue baru, dan penghematan gaji belum dibuktikan.

### 05 As Is No Action and To Be

As-Is adalah baseline observed revenue MYR 7.074.461,68, biaya MYR 6.216.045,66, dan kontribusi MYR 858.416,02. No-Action adalah pengulangan cohort dengan volume/biaya sama, bukan ramalan. To-Be memakai parameter di tabel; semua OPEX tahunan dikalikan dua agar sesuai horizon 24 bulan. Seluruh hasil merupakan skenario bersyarat.

### 06 Recommendation Risk and Assumptions

Uji pengaturan kedatangan dengan biaya tercatat. Tidak merekomendasikan software berbayar berdasarkan model saat ini; biaya SOP sederhana pun harus dihitung.

Efektivitas, avoidable share, harga, kapasitas, dan hubungan mutu merupakan asumsi yang perlu divalidasi. Angka dataset sintetis tidak membuktikan hasil operasional lapangan.

### 07 Evidence File Paths and SQL References

- [Hasil query Q07](../../02_SQL/results/Q07_01.csv)
- [Model bersama](../../02_SQL/06_scenario_model.sql)
- [Perbandingan seluruh skenario](../../05_FINANCIAL/scenario_comparison.csv)
- [Sensitivitas](../../05_FINANCIAL/sensitivity.csv)
- [Asal bukti visual](../../03_CELONIS_EVIDENCE/README.md)

[Manifest asal bukti visual](../../03_CELONIS_EVIDENCE/README.md). Grafik mandiri terbaru: [Q07 SQL](../../03_CELONIS_EVIDENCE/Q07/Q07_scenario_sql.png).
