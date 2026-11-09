# Analisis Q09 · Prescriptive
## Milling Capacity Investment

### 01 Evidence & Data Source
- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q09.sql`
- **Visual Evidence**: `03_CELONIS_EVIDENCE/Q09/Q09_milling_capacity_investment_model.png`

#### Tabel Pemodelan Investasi Peningkatan Kapasitas Sterilisasi Sebesar 15%:
| Parameter Evaluasi Investasi | Skenario A: Permintaan Tetap (*Fixed Demand*) | Skenario B: Permintaan Tumbuh (*Growth Demand +15%*) | Satuan |
|---|---|---|---|
| **Jumlah Lot Diproses** | 189 Lot (Konstan) | 217 Lot (+28 Lot Tambahan) | Lot Olah |
| **Throughput Time Sterilisasi** | Turun dari 81,20 ke **70,61 Menit** | Turun dari 81,20 ke **70,61 Menit** | Menit / Lot |
| **Total Waktu Operasi Dihemat** | **33,36 Jam** (2.001,6 Menit) | Kapasitas Terserap Penuh | Jam Kerja Stasiun |
| **Waktu Antre Rata-rata (*Queue Delay*)** | Turun dari 12,21 ke **~2,80 Menit** | Stabil pada **~8,50 Menit** | Menit / Lot |
| **Tambahan Pendapatan Penjualan CPO** | **0,00 MYR** | **+530.538,32 MYR** (+2,33 Miliar IDR) | MYR / IDR |
| **Beban Investasi Mesin (*CAPEX*)** | **-110.000,00 MYR** (-482,34 Juta IDR) | **-110.000,00 MYR** (-482,34 Juta IDR) | MYR (Modifikasi Bejana Sterilizer) |
| **Biaya Energi Uap & Rawat (*OPEX*)** | **-15.000,00 MYR** (-65,77 Juta IDR) | **-15.000,00 MYR** (-65,77 Juta IDR) | MYR (Uap Boiler & Pelumas) |
| **Net Financial Benefit (MYR)** | **-125.000,00 MYR** | **+78.450,00 MYR** | **MYR** |
| **Net Financial Benefit (IDR)** | **-548.108.750,00 IDR** | **+344.011.746,50 IDR** | **IDR** |
| **Kelayakan Finansial (*Verdict*)** | **TIDAK LAYAK (RUGI)** | **LAYAK (Hanya jika pasokan buah naik)** | Keputusan Investasi |

---

### 02 Descriptive Finding
1. **Dampak Teknis Peningkatan Kapasitas 15%**:
   - Durasi siklus sterilisasi terpangkas sebesar 10,59 menit per lot (dari 81,20 menit menjadi 70,61 menit).
   - Menghemat total waktu operasi sterilizer sebesar 33,36 jam dan menurunkan waktu antrean buah di sterilizer ramp hingga di bawah 3 menit per lot.
2. **Kondisi Permintaan Tetap (*Fixed Demand*)**:
   - Jika volume pasokan TBS kebun dan kuota kontrak pembeli CPO bersifat tetap (189 lot), peningkatan kapasitas mesin **tidak menghasilkan satu ringgit pun pendapatan tambahan** (*Incremental Revenue = 0,00 MYR*).
   - Akibatnya, perusahaan harus menanggung biaya modal modifikasi sterilizer (MYR 110.000,00) dan biaya operasional uap tambahan (MYR 15.000,00), yang menghasilkan **kerugian bersih sebesar -125.000,00 MYR** (**-548,11 Juta IDR**).

---

### 03 Diagnostic Reasoning (Batas Interpretasi Kapasitas vs. Penjualan Kas)
- **Prinsip Utama Ekonomi Proses Industri**:
  - Sebagaimana ditegaskan dalam panduan (*"Batas interpretasi: capacity increase bukan otomatis incremental sales"*), kapasitas pabrik yang bertambah hanyalah menciptakan kapasitas menganggur (*idle capacity*) jika tidak diimbangi oleh ketersediaan bahan baku atau serapan pasar.
  - Mesin sterilisasi yang lebih cepat menyelesaikan perebusan buah hanya akan berhenti dan menunggu kedatangan batch berikutnya, sementara biaya penyusutan mesin dan kesiapan boiler tetap berjalan.

---

### 04 Business & Financial Implication
- Memaksakan investasi modal (*CAPEX*) sebesar MYR 110.000 pada fasilitas sterilisasi di saat pasokan kebun stagnan akan memangkas laba kontribusi perusahaan dari **MYR 858.416,02 menjadi MYR 733.416,02** (merosot sebesar 14,56%).

---

### 05 As-Is vs No-Action vs To-Be
- **As-Is**: Stasiun sterilisasi beroperasi pada utilisasi tinggi dengan antrean 12,21 menit.
- **No-Action**: Tidak melakukan ekspansi mesin (*zero CAPEX*) mempertahankan modal kerja perusahaan tetap utuh dan aman.
- **To-Be**: Tunda investasi fisik sterilizer; alihkan fokus ke penataan jadwal perebusan (*operational balancing*) antar tiga unit sterilizer yang ada tanpa mengeluarkan uang modal.

---

### 06 Recommendation, Risk, Assumptions
- **Rekomendasi**: **TOLAK investasi kapasitas sterilizer jika permintaan pasar dan luas panen kebun bersifat tetap**. Investasi baru boleh dipertimbangkan apabila Tanjung Palma membuka blok perkebunan baru atau menerima TBS dari petani swadaya sekitar (*third-party FFB off-taking*).
- **Risiko**: Risiko kelebihan beban (*overheat*) pada unit sterilizer FAC-029 jika distribusi beban perebusan tidak segera diperbaiki.
- **Asumsi**: Modifikasi sterilizer meningkatkan laju throughput sebesar 15% dengan estimasi CAPEX industri sebesar MYR 110.000.

---

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q09.sql`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/02_SQL/queries_by_question/Q09.sql)
- **Visual Chart (Evidence)**: [`03_CELONIS_EVIDENCE/Q09/Q09_milling_capacity_investment_model.png`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q09/Q09_milling_capacity_investment_model.png)
- **Tabel Pembanding**: [`05_FINANCIAL/scenario_comparison.csv`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/05_FINANCIAL/scenario_comparison.csv)
