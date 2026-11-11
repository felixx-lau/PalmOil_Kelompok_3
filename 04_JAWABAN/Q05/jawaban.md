# Analisis Q05 · Diagnostic
## Milling Facility Bottlenecks

**Revisi 11 November 2026.** CSV telah dibangun ulang melalui `00_import.sql`, `02_cleaning.sql`, `02b_patch_clean.sql`, validasi, dan ekspor ulang. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Seluruh query Q01–Q10 dihitung ulang dari rilis yang sama. Dataset sintetis; timestamp UTC. Satu event remittance dikarantina, sehingga satu dependensi penutupan lot memiliki pengecualian terdokumentasi.

### 01 Evidence & Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q10: `python3 02_SQL/run_pipeline.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Bukti antarmuka lama merupakan ilustrasi tambahan dengan asal aplikasi belum diverifikasi secara independen. Grafik baru berlabel SQL dibuat sendiri dengan Python, bukan ekspor Celonis; lihat manifest bukti.

- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q05.sql`
- **Tangkapan layar antarmuka lama**: `03_CELONIS_EVIDENCE/Q05/Q05_waiting_vs_processing_by_activity.png`

#### Tabel 1: Analisis Stasiun Pabrik Kelapa Sawit (Processing vs. Queue Delay):
| Aktivitas Stasiun Pabrik | Fasilitas Terlibat | Jumlah Eksekusi | Rata-rata Queue Wait (Menit) | Total Queue Wait (Jam) | Rata-rata Durasi Proses (Menit) | Total Durasi Proses (Jam) | Total Biaya Stasiun (MYR) | Status Bottleneck |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **FFB Sterilization Completed** | FAC-029, 030, 031 | 189 | **12,21** | **38,47** | **81,20** | **255,77** | 203.883,02 | **Kandidat #1 (satu episode 8–9 Mei)** |
| **Crude Oil Pressing Completed** | FAC-038, 039, 040 | 189 | 1,94 | 6,10 | 67,78 | 213,50 | 200.031,15 | Sekunder (#2) |
| **Oil Clarification Completed** | FAC-041, 042, 043 | 189 | 2,37 | 7,47 | 61,81 | 194,72 | 85.697,96 | Tersier (#3) |
| **Fruit Digestion Completed** | FAC-035, 036, 037 | 189 | 0,43 | 1,37 | 50,22 | 158,20 | 65.699,17 | Lancar |
| **Oil Purification Completed** | FAC-044, 045, 046 | 189 | 1,65 | 5,20 | 49,24 | 155,10 | 69.660,76 | Lancar |
| **FFB Threshing Completed** | FAC-032, 033, 034 | 189 | 0,00 | 0,00 | 46,21 | 145,55 | 77.863,53 | Lancar |
| **CPO Laboratory Tested** | FAC-047, 048, 049 | 216 | 0,04 | 0,13 | 35,69 | 128,47 | 16.626,13 | Lancar |
| **Mill Weighbridge Inbound** | FAC-020, 021 | 218 | 0,27 | 0,97 | 20,68 | 75,13 | 9.577,07 | Sangat Lancar |

#### Tabel 2: Distribusi Beban Fasilitas Sterilisasi (Constrained Resource Breakdown):
| Facility ID | Deskripsi Stasiun | Lot Ditangani | Rata-rata Antre (Menit) | Rata-rata Durasi (Menit) | Total Jam Beroperasi | Porsi Lot |
| --- | --- | --- | --- | --- | --- | --- |
| **FAC-029** | Sterilizer Unit 1 (Primary) | 150 | 6,42 | 79,19 | 197,97 Jam | 79,4% |
| **FAC-030** | Sterilizer Unit 2 (Secondary) | 21 | **34,62** | 90,67 | 31,73 Jam | 11,1% |
| **FAC-031** | Sterilizer Unit 3 (Secondary) | 18 | **34,33** | 86,89 | 26,07 Jam | 9,5% |

---

### 02 Descriptive Finding
1. **Identifikasi Bottleneck Utama**: Stasiun **Sterilisasi (*FFB Sterilization*)** adalah kandidat bottleneck terberat di pabrik, dengan total waktu operasi terlama (255,77 jam) dan waktu antre tertinggi (38,47 jam atau 2.308 menit). Seluruh 38,47 jam waiting sterilisasi tercatat pada **8–9 Mei 2026** (0,97 jam pada 8 Mei dan 37,50 jam pada 9 Mei); di luar dua hari itu waiting sterilisasi tepat nol, termasuk 129 eksekusi FAC-029. Karena itu antrean ini adalah **episode lonjakan dua hari, bukan keterbatasan kapasitas yang terbukti kronis**.
2. **Pemisahan Queue Delay vs Processing Delay**:
   - *Processing Delay*: Waktu perebusan uap (*sterilization cooking cycle*) rata-rata memakan waktu 81,20 menit per eksekusi.
   - *Queue Delay*: Terjadi penumpukan antrean rata-rata 12,21 menit per lot sebelum masuk sterilizer.
3. **Ketimpangan Beban Fasilitas (*Imbalanced Load*)**: Unit FAC-029 menangani 150 dari 189 lot (79,4%). Lot pada FAC-030 dan FAC-031 mencatat rata-rata antrean **34,62 menit** dan **34,33 menit** per lot, tetapi hampir seluruh eksekusi kedua unit itu terjadi pada episode 8–9 Mei. Pada hari lonjakan ketiga unit sama-sama sibuk: rata-rata waiting 45,86 (FAC-029), 40,39 (FAC-030), dan 34,33 menit (FAC-031), dengan beban kalender 9 Mei 85,97%, 85,56%, dan 89,38%. Jadi angka waiting yang lebih tinggi pada FAC-030/031 adalah efek episode, bukan bukti unit itu bermasalah.
4. **Kinerja Weighbridge**: Jembatan timbang bukan bottleneck (rata-rata antre hanya 0,27 menit dan durasi 20,68 menit).

---

### 03 Diagnostic Reasoning
Di antara delapan aktivitas stasiun yang dibandingkan, sterilisasi mencatat total processing dan waiting tertinggi. Ini mendukung penetapannya sebagai kandidat bottleneck operasional, tetapi durasi proses terpanjang saja tidak membuktikan kapasitasnya kurang. Jumlah pada tabel pertama adalah eksekusi event: laboratorium memiliki 216 eksekusi karena ada pengujian ulang, bukan 216 lot unik.

FAC-029 menangani 79,4% lot sterilisasi; angka tersebut adalah porsi lot, bukan utilisasi waktu. Unit lain memiliki rata-rata waiting lebih tinggi, tetapi log belum membuktikan bahwa penyebabnya prioritas operator atau persiapan boiler. Q03 menunjukkan antrean terkonsentrasi di Mei 2026 dan beban FAC-029 mencapai sekitar 86% dari 24 jam kalender pada 9 Mei. Jadwal operasi, downtime, serta interval tumpang tindih perlu diperiksa untuk menghitung utilisasi aktual.

Dalam urutan proses Q01, sterilisasi berlangsung setelah pembongkaran di ramp dan sebelum threshing atau perontokan. Aliran ini menjadi dasar pemeriksaan apakah antrean di sterilisasi menahan lot pada tahap penerimaan.

### 04 Business and Financial Implication
Biaya aktivitas sterilisasi adalah MYR 203.883,02, tertinggi di antara delapan aktivitas stasiun pada tabel. Ini seluruh biaya aktivitas, bukan biaya antrean yang pasti dapat dihemat. Total waiting 38,47 jam merupakan penjumlahan waiting lot; membaginya dengan waktu proses per lot tidak membuktikan tersedianya kapasitas untuk 28 lot tambahan karena antrean dapat terjadi bersamaan. Tambahan produksi dan laba memerlukan pasokan, permintaan, dan kapasitas rangkaian stasiun yang memadai.

### 05 As Is No Action and To Be
- **As-Is**: Rata-rata processing sterilisasi 81,20 menit dan waiting 12,21 menit per eksekusi; waiting rata-rata unit FAC-030 dan FAC-031 sekitar 34,5 menit.
- **No-Action**: Dengan pola kedatangan dan kesiapan fasilitas yang sama, antrean pada hari puncak berpotensi berulang. Log belum mengukur tambahan keausan mesin atau kerugian mutu akibat antrean ini.
- **To-Be**: Uji pemerataan beban dan pengaturan kedatangan pada hari puncak. Penurunan waiting 75% merupakan target uji, bukan hasil terukur. Perubahan durasi siklus perlu validasi teknis dan mutu sebelum diterapkan; keputusan CAPEX dibahas di Q09.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Periksa kapasitas efektif dan kesiapan tiga unit saat lonjakan sebelum membeli mesin baru; pantau waiting per hari dan fasilitas melalui DuckDB.
- **Risiko**: Memindahkan lot ke unit lain dapat memindahkan antrean ke stasiun berikutnya. Memperpendek proses tanpa validasi dapat menurunkan mutu.
- **Batasan**: Dataset belum menyediakan kalender kapasitas efektif untuk menghitung utilisasi aktual atau pendapatan tambahan akibat pengurangan waiting.

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q05.sql`](../../02_SQL/queries_by_question/Q05.sql)
- **Visual Chart (Evidence)**: [`Q05_waiting_vs_processing_by_activity.png`](../../03_CELONIS_EVIDENCE/Q05/Q05_waiting_vs_processing_by_activity.png), [`Q05_sterilization_by_facility.png`](../../03_CELONIS_EVIDENCE/Q05/Q05_sterilization_by_facility.png)


Hasil DuckDB yang mendasari tabel:

- [Hasil query 1](../../02_SQL/results/Q05_01.csv)
- [Hasil query 2](../../02_SQL/results/Q05_02.csv)

- [Total waiting per tahap di Q05](../../02_SQL/results/Q05_03.csv)
- [Beban kalender harian semua fasilitas di Q05](../../02_SQL/results/Q05_04.csv)

Beban harian membagi interval pada tengah malam, menggunakan 24 jam kalender sebagai denominator, dan hanya menampilkan hari dengan aktivitas. Validasi rilis mendeteksi nol overlap pada fasilitas dan employee. Beban kalender tetap berbeda dari utilisasi jam kerja efektif dan OEE.

[Manifest asal bukti visual](../../03_CELONIS_EVIDENCE/README.md). Grafik mandiri terbaru: [Q05 SQL](../../03_CELONIS_EVIDENCE/Q05/Q05_daily_load_sql.png).
