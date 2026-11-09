# Presentasi Analisis Proses Bisnis (Option A: Q01–Q10)
## Tanjung Palma Agro-Industrial Estate — Palm Oil Agriculture and Processing
**Kelompok**: 24SI1 • GROUP 03  
**Format Presentasi**: 15 Menit Presentasi + 5 Menit Q&A  
**Konversi Kurs BI (13 Okt 2026)**: 1 MYR = 4.384,87 IDR  
**File Presentasi Resmi**: `06_PRESENTATION/slides.pdf`

---

### Slide 1: Company Context & Business Challenge
- **Profil Perusahaan**: Tanjung Palma Agro-Industrial Estate (perkebunan kelapa sawit dan pabrik CPO terintegrasi).
- **Cakupan Dataset**: 230 processing lot yang dipanen pada periode simulasi Oktober 2024 hingga September 2026.
- **Unit of Analysis (Case Notion)**: Satu batch panen TBS (*Fresh Fruit Bunches*) yang ditelusuri sebagai lot pengolahan hingga pengapalan CPO.
- **Business Challenge**: Mengurangi lonjakan reject buah di pabrik dan memangkas waktu tunggu logistik kebun tanpa menurunkan standar mutu CPO komersial.
- **Alur Metodologis Wajib**: Raw CSV $\rightarrow$ Profiling $\rightarrow$ Cleaning $\rightarrow$ Validation $\rightarrow$ Cleaned Export $\rightarrow$ Celonis Analysis $\rightarrow$ Business Case.

---

### Slide 2: Data Quality & Cleaning Decisions
- **Volume Awal Raw Log**: 6.325 baris transaksi mentah.
- **Deduplikasi (145 baris dibersihkan)**: 143 event_id ganda akibat replikasi ekstraksi dibersihkan menggunakan window function ranking; seluruh pengerjaan ulang (*rework*) sah memiliki event_id unik dan dipertahankan 100%.
- **Karantina Data Korup (1 baris)**: Record `RAW-0005170` (event `EVT-0000623`, *Buyer Remittance Matched*) dikarantina karena timestamp bernilai `'not-a-time'` demi mencegah fabrikasi data buatan.
- **Perbaikan Timestamp Terbalik (17 baris)**: Menukar kolom `activity_start_time` dan `activity_end_time` yang terbalik saat logging sehingga konsisten dengan durasi dan timestamp end.
- **Pembersihan Simbol Finansial**: Menghapus teks `'RM'` dan `'MYR'` pada 17 nilai angka dan merekonstruksi 3 nilai `material_cost` yang hilang via persamaan neraca biaya.
- **Hasil Bersih**: **6.179 completed events** dan **230 unique case lots** yang 100% cocok dengan `case_master.csv`.

---

### Slide 3: Financial Baseline & Kurs Bank Indonesia (13 Oktober 2026)
- **Sumber Resmi BI**: Kurs Transaksi Bank Indonesia per 13 Oktober 2026.
  - Kurs Jual: 4.408,94 IDR | Kurs Beli: 4.360,80 IDR | **Reference Rate (Midpoint) = 4.384,87 IDR per 1 MYR**.
- **Metrik Finansial Baseline As-Is (230 Lot)**:
  - **Net Recognized Revenue**: **7.074.461,68 MYR** (**31.020.593.293,47 IDR**)
  - **Total Operational Cost**: **6.216.045,66 MYR** (**27.256.552.698,81 IDR**)
  - **Net Profit Contribution**: **858.416,02 MYR** (**3.764.040.594,66 IDR**)
  - **Average Cost per Lot**: **27.026,29 MYR** (**118.506.750,86 IDR**)

---

### Slide 4: Q01 · Harvest-to-CPO Process Discovery & Variants
- **Varian 1 (Happy Path - 61 Lot / 26,52%)**: Alur standard panen hingga penjualan. Throughput: 19,76 jam, Kontribusi: **+9.020,64 MYR/lot** (Total: +550.259,04 MYR).
- **Varian 2 (Early Mill Rejection - 23 Lot / 10,00%)**: Buah dipanen & diangkut ke pabrik, namun ditolak di intake. Throughput: 8,44 jam, Kontribusi: **-23.914,16 MYR/lot** (Total rugi: **-550.025,68 MYR**).
- **Varian 3 (Agile Dispatched - 17 Lot / 7,39%)**: Operasi pemurnian minyak & pemisahan kernel berjalan paralel. Throughput: 17,13 jam, Kontribusi: **+9.270,96 MYR/lot**.
- **Implikasi Utilisasi**: Varian 2 menyerap 10% jam truk dan jembatan timbang namun menghasilkan 0 output bagi stasiun perebusan dan press pabrik.

---

### Slide 5: Q02 · FFB Outcomes & Cost Leakage
- **Processed / Dispatched (189 Lot / 82,17%)**: Menghasilkan 100% pendapatan (MYR 7,07 Juta) dan laba kontribusi **+1.571.708,26 MYR**.
- **Rejected Lots (29 Lot / 12,61%)**: Kebocoran modal langsung sebesar **-711.861,41 MYR (-3,12 Miliar IDR)**.
- **Cancelled Lots (12 Lot / 5,22%)**: Dibatalkan sebelum panen, biaya minimal (MYR 1.430,83 untuk perencanaan).
- **Sunk Feedstock Risk**: 94,8% biaya lot reject adalah biaya tanam buah yang hangus saat panen (MYR 675.040,72).
- **Total Economic Damage**: Biaya riil ditambah peluang laba hilang mencapai **953.023,09 MYR (4,18 Miliar IDR)**.

---

### Slide 6: Q03 · Plantation-to-Mill Performance & SLA
- **Konsentrasi Pelanggaran SLA**: Sebanyak **98,33% (177 dari 180)** pelanggaran SLA di seluruh perusahaan terjadi pada tahap **Plantation / Harvesting**.
- **Penyumbang Antrean Terbesar**: Tahap kebun mengakumulasi 818 jam waktu antre (rata-rata 35,93 menit per aktivitas).
- **Aktivitas Paling Kritis**: *Harvest Batch Created* (58 viol), *Palm Ripeness Assessed* (46 viol), dan *FFB Field Grading* (43 viol).
- **Stabilitas Tahap Pabrik**: Tahap Milling dan Weighbridge mencatat 100% kepatuhan SLA (0 pelanggaran).
- **Prioritas Utama**: Koordinasi penugasan regu panen dan penilai kematangan di kebun adalah prioritas perbaikan #1.

---

### Slide 7: Q04 · Time-to-Mill Lead Time & FFB Quality
- **Waktu Tempuh Optimal (2–3 Jam)**: Mencatat tingkat penolakan terendah, yaitu hanya **7,53%**.
- **Lonjakan Penolakan (>3 Jam)**: Pada durasi 3–4 jam, penolakan melonjak drastis hingga **22,58%**.
- **Mekanisme Biologis**: Enzim lipase teraktivasi akibat luka potong buah; paparan panas saat transit mempercepat hidrolisis menjadi FFA.
- **Ketiadaan Kausalitas Tunggal**: Lot yang diangkut sangat cepat (<2 jam) tetap ditolak sebesar 18,18%, membuktikan adanya faktor independen hulu: **fraksi kematangan buah saat dipetik di kebun**.
- **Kerugian Total Reject**: **711.861,41 MYR (3,12 Miliar IDR)**.

---

### Slide 8: Q05 · Milling Facility Bottlenecks & Capacity
- **Bottleneck Utama Pabrik (#1)**: **FFB Sterilization** (Perebusan Uap), menyerap 255,77 jam operasi (81,2 menit/lot) dan 38,47 jam antrean.
- **Bottleneck Sekunder (#2 & #3)**: Kempa Minyak (*Pressing*, 67,8 min) dan Klarifikasi (*Clarification*, 61,8 min).
- **Ketimpangan Beban Sterilizer**: Unit FAC-029 menangani 79,4% lot (antre 6,4 min). Ketika overload, antrean pada unit sekunder FAC-030 dan FAC-031 melonjak hingga **34,6 menit/lot**.
- **Jembatan Timbang Lancar**: Weighbridge bukan bottleneck (rata-rata antre hanya 0,27 menit/lot).
- **Peluang Kapasitas**: Waktu antre 38,5 jam di sterilizer setara dengan potensi kapasitas untuk mengolah ~28 lot tambahan.

---

### Slide 9: Q06 · Quality Rework & Commercial Sales Allowances
- **Data Duplicates (Technical Defect)**: 145 baris ekstraksi ganda dengan event_id dan waktu sama; telah dibersihkan.
- **Legitimate Rework (Physical Retest)**: Eksekusi fisik ulang yang sah dengan event_id baru dan waktu baru untuk menjaga kepatuhan mutu (tagged rework_flag = true).
- **Biaya Rework Tercatat (MYR 21.823,19)**: CPO Quality Rework (27 kasus = MYR 18.469,49), Uji Ulang Lab (27 kasus = MYR 2.308,02), dan Grading Kebun (22 kasus = MYR 1.045,68).
- **Klaim Denda Pembeli (*Sales Allowances*)**: 14 lot mengalami potongan harga faktur akibat penalti mutu sebesar **-20.949,08 MYR**.
- **Total Beban Kegagalan Mutu**: **43.193,28 MYR (189,4 Juta IDR)**.

---

### Slide 10: Q07 · Prescriptive: FFB Transport Scheduling
- **Manfaat Waktu**: Menghemat 25,88 jam antrean truk (dari 129,4 jam menjadi 103,5 jam), atau ~7,1 menit per rit pengangkutan.
- **Manfaat Biaya Kas (Avoidable Cost)**: Hanya 12% dari biaya truk yang dapat dihemat (BBM mesin menyala diam / idle fuel = MYR 3.290,00). Supir truk adalah karyawan bulanan tetap.
- **Manfaat Kualitas**: Tidak dapat diasumsikan tanpa indikator empiris; penghematan 7 menit tidak signifikan terhadap laju FFA.
- **Beban Biaya Sistem**: Biaya software dispatch (MYR 6.000) + OPEX (MYR 1.200) = MYR 7.200.
- **Hasil Finansial Bersih**: **Net Loss sebesar -3.910,00 MYR (-17,14 Juta IDR)**. Jangan jalankan sistem berbayar mandiri!

---

### Slide 11: Q08 · Prescriptive: FFB Grading Improvement
- **Volume Diselamatkan**: Menyelamatkan **4,35 lot** dari penolakan gerbang pabrik (15% dari 29 lot).
- **Pendapatan Penjualan Tambahan**: $4,35 \times 37.431\text{ MYR} = \mathbf{+162.824,89\text{ MYR}}$ (+713,97 Juta IDR).
- **Logika Sunk Cost Buah**: Biaya tanam kebun (MYR 23.277/lot) sudah hangus saat panen; memproses buah menjadi CPO **tidak mengeluarkan biaya tanam baru**.
- **Biaya Olah Tambahan (Marginal Milling)**: $4,35 \times 5.672\text{ MYR} = -24.673,46\text{ MYR}$.
- **Beban Program**: CAPEX alat uji NIR portabel (MYR 20.000) + OPEX (MYR 5.000).
- **Net Financial Benefit**: **+113.151,43 MYR (+496,15 Juta IDR) | ROI = 452,6%**. **PRIORITAS UTAMA #1**.

---

### Slide 12: Q09 · Prescriptive: Milling Capacity Investment
- **Dampak Operasional**: Siklus perebusan turun dari 81,2 menit menjadi 70,6 menit (menghemat 33,4 jam operasi).
- **Kasus Permintaan Tetap (Fixed Demand - 189 Lot)**: Penjualan baru = 0,00 MYR. Perusahaan menanggung CAPEX (MYR 110.000) dan OPEX uap (MYR 15.000). **Rugi bersih = -125.000,00 MYR (-548,11 Juta IDR)**.
- **Kasus Permintaan Tumbuh (+15% Panen Baru)**: Laba bersih positif +78.450 MYR.
- **Prinsip Evaluasi**: *'Capacity increase bukan otomatis incremental sales'*. Menambah mesin pada permintaan tetap hanya menciptakan kapasitas menganggur.
- **Keputusan Manajemen**: **TOLAK investasi fisik sterilizer**; gunakan penataan jadwal perebusan internal.

---

### Slide 13: Q10 · Prescriptive: Business Case Prioritization
- **Prioritas 1 (Q08 - Grading Kebun di TPH)**: Net Benefit **+113.151,43 MYR (+496,15 Juta IDR)**. Memulihkan sunk cost buah yang dibuang.
- **Prioritas 2 (Q06 - Stabilisasi Mutu CPO)**: Net Benefit **+9.703,82 MYR (+42,55 Juta IDR)**. Mengurangi 50% klaim penalti mutu pembeli dan 40% retest lab.
- **Peringkat 3 (Q07 - Transport Scheduling)**: Net Benefit -3.910 MYR (Biaya software > penghematan BBM).
- **Peringkat 4 (Q09 - Sterilizer CAPEX)**: Net Benefit -125.000 MYR (Investasi mesin tidak layak pada demand tetap).
- **Portofolio Rekomendasi (P1 + P2)**: Memberikan total keuntungan bersih **+122.855,25 MYR (+538,70 Juta IDR)**.

---

### Slide 14: Financial Scenario Comparison (As-Is vs No-Action vs To-Be)
| Indikator Finansial | Kondisi As-Is | No-Action Scenario | Rekomendasi To-Be (P1+P2) | Pertumbuhan Finansial |
|---|---|---|---|---|
| **Pendapatan Bersih (MYR)** | 7.074.461,68 MYR | 7.074.461,68 MYR | **7.247.761,11 MYR** | +173.299,43 MYR |
| **Pendapatan Bersih (IDR)** | 31.020.593.293 IDR | 31.020.593.293 IDR | **31.780.487.043 IDR** | +759.893.749 IDR |
| **Total Biaya Operasional (MYR)** | 6.216.045,66 MYR | 6.216.045,66 MYR | **6.266.489,84 MYR** | +50.444,18 MYR |
| **Total Biaya Operasional (IDR)** | 27.256.552.699 IDR | 27.256.552.699 IDR | **27.477.743.266 IDR** | +221.190.567 IDR |
| **Profit Contribution (MYR)** | **858.416,02 MYR** | **858.416,02 MYR** | **981.271,27 MYR** | **+122.855,25 MYR (+14,31%)** |
| **Profit Contribution (IDR)** | **3.764.040.595 IDR** | **3.764.040.595 IDR** | **4.302.744.889 IDR** | **+538.704.294 IDR (+14,31%)** |
| **Total Investasi Program (MYR)** | 0,00 MYR | 0,00 MYR | **28.000,00 MYR** | Payback < 6 Bulan |

---

### Slide 15: Management Recommendations & Strategic Action Plan
1. **Eksekusi Segera Prioritas 1 (Q08 - Grading Kebun di TPH)**: Alokasikan CAPEX MYR 20.000 pada Q1 2027 untuk pengadaan 4 unit scanner NIR portabel dan SOP penolakan buah di TPH sebelum dimuat ke truk.
2. **Eksekusi Prioritas 2 (Q06 - Otomasi Kontrol Suhu Pemurnian Minyak)**: Alokasikan MYR 8.000 untuk sensor suhu di purifier dan vacuum dryer guna mencegah denda klaim mutu dari pembeli.
3. **Tolak Belanja Modal Mesin Baru (Q09) & Software Truk (Q07)**: Jangan beli mesin sterilisasi baru (hemat MYR 110.000) dan software dispatch truk (hemat MYR 6.000) karena tidak memberikan pengembalian kas positif.
4. **Rencana Pengendalian Risiko**: Luncurkan skema insentif kualitas panen bagi mandor dan terapkan batas waktu maksimal pengangkutan dari panen ke pabrik $\le 3,0$ jam.
- **Total Dampak Keberhasilan**: Meningkatkan laba kontribusi perusahaan menjadi **4,30 Miliar IDR** (+14,31%).

---

### Slide 16: Appendix & Audit Trail References
- Cleaned Event Log CSV: `01_DATA/cleaned/celonis_event_log_clean.csv` (6.179 event / 230 lot).
- Laporan Kualitas Data: `01_DATA/validation/data_quality_report.md` (Dokumentasi karantina RAW-0005170).
- Naskah SQL DuckDB: `02_SQL/` (00_import.sql s/d 05_celonis_export.sql) dan `queries_by_question/Q01.sql s/d Q10.sql`.
- Bukti Visual Celonis: `03_CELONIS_EVIDENCE/` (13 grafik analisis proses & finansial resolusi tinggi).
- Jawaban Lengkap Q01–Q10: `04_JAWABAN/Q01/jawaban.md` hingga `04_JAWABAN/Q10/jawaban.md`.
- Dokumentasi Kurs BI & Finansial: `05_FINANCIAL/exchange_rate.csv` (1 MYR = 4.384,87 IDR per 13 Okt 2026).
- Executive Summary: `07_EXECUTIVE_SUMMARY/executive_summary.pdf` | Kontribusi Anggota: `08_CONTRIBUTIONS/`.
