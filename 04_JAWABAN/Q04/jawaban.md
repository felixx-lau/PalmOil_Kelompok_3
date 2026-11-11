# Analisis Q04 · Diagnostic
## Time-to-Mill and FFB Quality

### 01 Evidence & Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q06: `python3 02_SQL/export_q01_q06_results.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Gambar Celonis merupakan ilustrasi tambahan.

- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q04.sql`
- **Ilustrasi tambahan**: `03_CELONIS_EVIDENCE/Q04/Q04_harvest_to_mill_by_grade.png`

#### Tabel 1: Hubungan Durasi Panen-ke-Pabrik (*Harvest-to-Mill Lead Time*) terhadap Penolakan:
| Kelompok Waktu (*Lead Time Bucket*) | Rentang Waktu Tempuh | Jumlah Lot Tiba | Jumlah Lot Ditolak | Tingkat Penolakan (%) | Rata-rata Durasi (Jam) | Total Kerugian Biaya Lot Ditolak (MYR) |
| --- | --- | --- | --- | --- | --- | --- |
| **1. Cepat** | $< 2,0$ Jam | 33 | 6 | 18,18% | 1,79 | 133.719,52 |
| **2. Standar** | $2,0 - 3,0$ Jam | 93 | 7 | **7,53%** | 2,36 | 157.352,90 |
| **3. Terlambat Sedang** | $3,0 - 4,0$ Jam | 31 | 7 | **22,58%** | 3,41 | 193.935,13 |
| **4. Terlambat Berat** | $> 4,0$ Jam | 61 | 9 | **14,75%** | 8,16 | 226.853,86 |
| **Total Lot Tiba di Pabrik** | — | **218** | **29** | **13,30%** | **4,05** | **711.861,41** |

#### Tabel 2: Hubungan Provisional FFB Grade terhadap Penolakan:
| Provisional FFB Grade | Total Lot Panen | Jumlah Ditolak | Tingkat Penolakan (%) | Rata-rata Durasi ke Pabrik (Jam) | Total Biaya Lot Ditolak (MYR) |
| --- | --- | --- | --- | --- | --- |
| **Grade A** (High Quality) | 94 | 11 | 11,70% | 3,93 | 289.952,06 |
| **Grade B** (Standard) | 77 | 10 | 12,99% | 4,17 | 232.974,12 |
| **Grade C** (Mixed/Low) | 44 | 7 | **15,91%** | 4,13 | 163.392,20 |
| **Unknown** (Provisional Pending) | 3 | 1 | **33,33%** | 3,04 | 25.543,03 |

---

### 02 Descriptive Finding
1. **Total Kerugian Lot TBS Ditolak**: Kerugian biaya kumulatif akibat 29 lot TBS yang ditolak di pabrik mencapai **711.861,41 MYR** (**3,12 Miliar IDR**).
2. **Kelompok dengan Penolakan Terendah dalam Sampel**: Kelompok waktu tempuh standar (2,0–3,0 jam) menghasilkan tingkat penolakan paling rendah, yaitu hanya **7,53%**.
3. **Peningkatan Penolakan pada Waktu Tempuh Panjang**: Pada lot yang menempuh waktu lebih dari 3 jam, tingkat penolakan tercatat lebih tinggi hingga **22,58%** pada rentang 3–4 jam, dan rata-rata 14,75% pada kelompok $>4$ jam.
4. **Anomali Waktu Singkat**: Kelompok $<2,0$ jam tetap mencatat penolakan tinggi sebesar 18,18% (6 lot ditolak).

---

### 03 Diagnostic Reasoning
DuckDB menghitung lead time dari akhir `FFB Harvested` sampai awal `Mill Weighbridge Inbound`, bukan durasi perjalanan truk saja. Interval tersebut juga dapat mencakup grading, pemuatan, dan waktu tunggu di antaranya. Kelompok waktu dibentuk dari jam yang dibulatkan dua desimal sesuai query; batas 3,00 jam masuk kelompok standar.

Kelompok 2–3 jam memiliki rejection rate terendah dalam sampel, tetapi hubungan waktu dengan penolakan tidak meningkat secara konsisten: kelompok di bawah 2 jam mencapai 18,18%, sedangkan di atas 4 jam 14,75%. Hasil ini menunjukkan asosiasi, bukan bukti bahwa delay menyebabkan reject. Grade, kondisi lot, blok kebun, dan periode lonjakan dapat menjadi faktor lain. Grade Unknown hanya berisi tiga lot sehingga persentasenya tidak stabil. Kolom grade dipakai sebagai grade provisional sesuai dataset; perlu verifikasi definisinya sebelum menafsirkannya sebagai mutu akhir.

### 04 Business and Financial Implication
Sebanyak 29 lot reject mencatat biaya MYR 711.861,41 tanpa revenue. Dari biaya tersebut, MYR 420.788,99 berada pada kelompok lebih dari 3 jam (16 reject), tetapi angka ini merupakan biaya lot, bukan kerugian yang terbukti disebabkan delay atau penghematan yang pasti dapat dipulihkan. Biaya reject sudah masuk baseline kontribusi MYR 858.416,02 sehingga tidak dikurangkan lagi.

### 05 As Is No Action and To Be
- **As-Is**: 92 dari 218 lot panen (42,20%) memiliki lead time lebih dari 3 jam; 16 dari 92 lot tersebut ditolak (17,39%). Kelompok sampai 3 jam mencatat 13 reject dari 126 lot (10,32%).
- **No-Action**: Jika komposisi volume, mutu, dan biaya sama, risiko kontribusi negatif pada reject dapat berulang; data 24 bulan tidak membuktikan kerugian tersebut terjadi setiap tahun atau setiap siklus panen.
- **To-Be**: Uji target lead time maksimal 3 jam bersama pemeriksaan mutu awal. Rejection rate maksimal 8% diperlakukan sebagai target pilot, bukan hasil model yang sudah terbukti. Nilai manfaat harus diuji dengan kelompok pembanding dan biaya implementasi pada horizon yang sama.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Telusuri alasan reject, pisahkan interval panen–grading–pemuatan–perjalanan, lalu prioritaskan tahap penyumbang keterlambatan berdasarkan DuckDB.
- **Risiko**: Mengejar durasi saja dapat mengabaikan kualitas awal; memajukan penolakan tidak otomatis menghasilkan tambahan CPO layak jual.
- **Batasan**: Tidak ada bukti per lot yang memastikan kadar FFA, kematangan buah, atau ambang kontrak sebagai penyebab reject. Kesimpulan kausal memerlukan catatan inspeksi dan hasil pengujian mutu.

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q04.sql`](../../02_SQL/queries_by_question/Q04.sql)
- **Visual Chart (Evidence)**: [`Q04_harvest_to_mill_by_grade.png`](../../03_CELONIS_EVIDENCE/Q04/Q04_harvest_to_mill_by_grade.png), [`Q04_rejection_by_grade.png`](../../03_CELONIS_EVIDENCE/Q04/Q04_rejection_by_grade.png)


Hasil DuckDB yang mendasari tabel:

- [Hasil query 1](../../02_SQL/results/Q04_01.csv)
- [Hasil query 2](../../02_SQL/results/Q04_02.csv)
