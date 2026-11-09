# Panduan Penyerahan & Reprodusibilitas Analisis Proses Bisnis
# Tanjung Palma Agro-Industrial Estate — FFB Harvest-to-CPO Processing
**Mata Kuliah**: Process Mining • Final Group Assignment  
**Kelas & Kelompok**: 24SI1 • GROUP 03  
**Horizon Simulasi**: Oktober 2024 – September 2026 (24 Bulan / 230 Processing Lot)  
**Kurs Referensi Transaksi Bank Indonesia (13 Oktober 2026)**: **1 MYR = 4.384,87 IDR**  

---

## 1. Ikhtisar Penyerahan Tugas (Submission Package Overview)
Proyek ini merupakan analisis komprehensif rantai pasok agribisnis kelapa sawit terintegrasi dari kebun (*plantation*) hingga pengapalan minyak sawit mentah (*CPO dispatch*). 
Seluruh berkas telah disusun secara modular dan terstruktur dalam satu folder induk **`24SI1_Group03_Palm_Oil/`** sesuai ketentuan buku panduan resmi tugas (*Student Brief & Assessment Rubric*), di mana isi setiap deliverable ditempatkan pada subfoldernya masing-masing dan **tidak digabung menjadi satu file**:

```text
24SI1_Group03_Palm_Oil/
├── 00_START_HERE/
│   └── README.md                                  # Panduan utama navigasi dan tata kelola submission
├── 01_DATA/
│   ├── raw/                                       # 9 file CSV master dan transaksi sumber
│   │   ├── raw_event_log.csv
│   │   ├── activity_catalog.csv
│   │   ├── case_master.csv
│   │   ├── department_master.csv
│   │   ├── employee_master.csv
│   │   ├── estate_block_master.csv
│   │   ├── facility_master.csv
│   │   ├── ffb_grade_master.csv
│   │   └── resource_master.csv
│   ├── cleaned/
│   │   └── celonis_event_log_clean.csv            # Cleaned Event Log siap ingest Celonis (6.179 baris)
│   └── validation/
│       └── data_quality_report.md                 # Laporan audit kualitas data & log karantina
├── 02_SQL/
│   ├── 00_import.sql                              # Ingest CSV mentah ke tabel DuckDB
│   ├── 01_profiling.sql                           # Script deteksi anomali, duplikat, dan format
│   ├── 02_cleaning.sql                            # Pipeline pembersihan, perbaikan jam & normalisasi
│   ├── 03_validation.sql                          # Uji validitas integritas referensial & finansial
│   ├── 04_financial_analysis.sql                  # Praktik finansial DuckDB (Practice 01-06)
│   ├── 05_celonis_export.sql                      # Ekspor dataset bersih ke celonis_event_log_clean.csv
│   └── queries_by_question/                       # Script SQL terpisah per nomor soal
│       ├── Q01.sql ... Q10.sql
├── 03_CELONIS_EVIDENCE/
│   ├── process_map/                               # Visualisasi peta alur proses end-to-end
│   ├── process_variants/                          # Distribusi varian proses
│   ├── performance_analysis/                      # Analisis timeline tahapan & antrean
│   └── Q01/ ... Q10/                              # Bukti visual & grafik spesifik per nomor soal
├── 04_JAWABAN/
│   ├── Q01/jawaban.md ... Q10/jawaban.md          # 10 dokumen jawaban (Template Wajib 7 Seksi)
├── 05_FINANCIAL/
│   ├── exchange_rate.csv                          # Data kurs harian resmi BI 13 Oktober 2026
│   ├── financial_baseline.csv                     # Neraca baseline As-Is dalam MYR dan IDR
│   ├── scenario_comparison.csv                    # Tabel komparasi kuantitatif As-Is vs No-Action vs To-Be
│   ├── scenario_assumptions.md                    # Dokumentasi lengkap asumsi ekonomi, CAPEX & OPEX
│   └── bank_indonesia_evidence/
│       └── kurs_bi_evidence.md                    # Bukti resmi tangkapan data kurs Bank Indonesia
├── 06_PRESENTATION/
│   ├── slides.pdf                                 # Slide presentasi resmi 16 slide landscape
│   └── slides.md                                  # Transkrip lengkap slide dalam format markdown
├── 07_EXECUTIVE_SUMMARY/
│   ├── executive_summary.pdf                      # Executive Summary resmi 2 halaman PDF
│   └── executive_summary.md                       # Naskah Executive Summary lengkap
├── 08_CONTRIBUTIONS/
│   └── member_contributions.csv                   # Matriks kontribusi individual anggota kelompok
└── 09_REFERENCES/
    └── sources.md                                 # Daftar pustaka akademik & standar industri sawit
```

---

## 2. Ringkasan Kinerja & Temuan Kunci Finansial

### 2.1 Baseline Finansial (As-Is)
- **Total Lot Panen**: 230 Case Lot (189 Processed / 29 Rejected / 12 Cancelled).
- **Total Completed Events**: 6.179 Event bersih.
- **Pendapatan Bersih (*Net Revenue*)**: **7.074.461,68 MYR** (**31.020.593.293,47 IDR**).
- **Total Biaya Operasional**: **6.216.045,66 MYR** (**27.256.552.698,81 IDR**).
- **Laba Kontribusi Bersih (*Profit Contribution*)**: **858.416,02 MYR** (**3.764.040.594,66 IDR**).
- **Rata-rata Biaya per Lot**: **27.026,29 MYR** (**118.506.750,86 IDR**).

### 2.2 Diagnostik Masalah Utama
1. **Kebocoran Lot Ditolak (*FFB Rejection*)**: Sebanyak 29 lot ditolak di pabrik, memusnahkan **711.861,41 MYR (3,12 Miliar IDR)** modal kerja yang mayoritas merupakan biaya budidaya kebun yang telah hangus (*sunk crop cost*).
2. **Keterlambatan Kebun**: 98,33% (177 dari 180) pelanggaran SLA terjadi pada tahap kebun (*Plantation/Harvesting*).
3. **Bottleneck Fasilitas Pabrik**: Stasiun Sterilisasi (*FFB Sterilization*) adalah bottleneck utama dengan siklus perebusan 81,2 menit dan total waktu antre 38,5 jam.
4. **Beban Pengerjaan Ulang & Diskon**: Rework minyak dan klaim denda mutu pembeli memangkas laba sebesar **43.193,28 MYR (189,40 Juta IDR)**.

### 2.3 Rekomendasi Portofolio To-Be
- **Prioritas 1 (Q08)**: Peningkatan Grading di TPH Kebun melalui scanner NIR $\rightarrow$ Net Benefit: **+113.151,43 MYR (+496,15 Juta IDR)**.
- **Prioritas 2 (Q06)**: Stabilisasi Mutu di Stasiun Klarifikasi $\rightarrow$ Net Benefit: **+9.703,82 MYR (+42,55 Juta IDR)**.
- **Keputusan Manajemen Terhadap Pilihan Lain**: Tolak pengadaan software truk berbayar (Q07: Net Benefit -3.910 MYR) dan tolak belanja mesin bejana sterilizer baru (Q09: Net Benefit -125.000 MYR pada permintaan tetap).
- **Hasil Skenario To-Be**: Laba kontribusi perusahaan melonjak dari 858.416,02 MYR menjadi **981.271,27 MYR (4.302.744.888,68 IDR)**, memberikan **pertumbuhan laba bersih +14,31% (+538,70 Juta IDR)** dengan masa pengembalian modal (*payback period*) di bawah 6 bulan!

---

## 3. Panduan Replikasi Eksekusi (Step-by-Step Reproduction Guide)

### Langkah 1 Analisis Q01 sampai Q06 menggunakan DuckDB
Buka terminal dari folder induk proyek dan pastikan package Python `duckdb` tersedia:

```bash
python3 02_SQL/export_q01_q06_results.py
```

Script membaca CSV bersih ke tabel `clean_events` dalam satu koneksi DuckDB, menjalankan query Q01–Q06, lalu mengekspor seluruh hasil SELECT ke `02_SQL/results/`. Python hanya menjalankan DuckDB dan menulis CSV; agregasi analisis dilakukan oleh SQL DuckDB. Pada revisi 9 November 2026, eksekusi menggunakan DuckDB 2.0.0 dan membaca 6.179 event dalam 230 case. Q01_04.csv memuat urutan lengkap aktivitas tiga varian terbesar.

Angka dan kesimpulan Q01–Q06 mengacu pada hasil DuckDB. Celonis berfungsi sebagai ilustrasi tambahan; selisih grouping varian pada screenshot lama tidak dipakai sebagai denominator analisis DuckDB. Query Q07–Q10 tetap tersedia terpisah. Bila pipeline pembersihan dijalankan ulang, gunakan satu database DuckDB persisten untuk seluruh tahap dan hitung ulang jawaban dari hasil ekspor baru.

### Langkah 2: Ingesti ke Celonis Process Mining
1. Buka workspace Celonis EMS / Celonis Academic Edition.
2. Buat Data Pool baru: `Tanjung Palma Palm Oil FFB-to-CPO`.
3. Unggah file CSV bersih: `01_DATA/cleaned/celonis_event_log_clean.csv`.
4. Konfigurasikan pemetaan kolom (*Activity Table Mapping*):
   - **Case ID**: `case_id`
   - **Activity**: `activity`
   - **Event Timestamp**: `timestamp`
   - **Sorting Column**: `timestamp` (secondary: `event_id`)
5. Tambahkan pemetaan atribut dimensi: `department`, `employee_role`, `facility_id`, `activity_total_cost`, `revenue_allocated`, `profit_contribution`, `ffb_grade`, `rework_flag`.
6. Simpan Data Model dan muat ke Celonis Studio Analysis.

---

## 4. Kepatuhan Rubrik Penilaian (Submission Quality Check)

| Persyaratan Rubrik | Bukti File Deliverable | Status Verifikasi |
|---|---|---|
| **Cleaned Event Log Valid** | `01_DATA/cleaned/celonis_event_log_clean.csv` | **TERPENUHI (6.179 baris, 230 lot)** |
| **Audit Trail Pembersihan Data** | `01_DATA/validation/data_quality_report.md` | **TERPENUHI (Deduplikasi, karantina, perbaikan jam)** |
| **DuckDB SQL Scripts** | `02_SQL/` (00 s/d 05 dan Q01–Q10) | **TERPENUHI (16 script SQL tuntas & teruji)** |
| **Celonis Visual Evidence** | `03_CELONIS_EVIDENCE/` (Q01–Q10 & proses) | **TERPENUHI (13 file visual png resolusi tinggi)** |
| **Jawaban Q01 s/d Q10 Lengkap** | `04_JAWABAN/Q01/` s/d `Q10/jawaban.md` | **TERPENUHI (Format wajib 7 seksi per soal)** |
| **Dokumentasi Kurs Bank Indonesia** | `05_FINANCIAL/exchange_rate.csv` | **TERPENUHI (Kurs BI 13 Okt 2026: 4.384,87 IDR)** |
| **Model Perbandingan Skenario** | `05_FINANCIAL/scenario_comparison.csv` | **TERPENUHI (As-Is vs No-Action vs To-Be)** |
| **Slide Presentasi 15 Menit** | `06_PRESENTATION/slides.pdf` (& `slides.md`) | **TERPENUHI (16 slide landscape profesional)** |
| **Executive Summary 2 Halaman** | `07_EXECUTIVE_SUMMARY/executive_summary.pdf` | **TERPENUHI (Format ringkas eksekutif PDF & MD)** |
| **Catatan Kontribusi Anggota** | `08_CONTRIBUTIONS/member_contributions.csv` | **TERPENUHI (Peran, output, dan pembagian tugas)** |
| **Daftar Pustaka & Rujukan** | `09_REFERENCES/sources.md` | **TERPENUHI (Standar MPOB, RSPO, BI, Aalst)** |
