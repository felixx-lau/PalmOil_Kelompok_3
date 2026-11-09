# EXECUTIVE SUMMARY: LAPORAN ANALISIS PROSES BISNIS & REKOMENDASI MANAJEMEN
## Evaluasi Kinerja Rantai Pasok FFB Harvest-to-CPO Dispatch & Collection
**Perusahaan**: Tanjung Palma Agro-Industrial Estate  
**Tim Konsultan**: 24SI1 • GROUP 03  
**Horizon Simulasi**: Oktober 2024 – September 2026 (24 Bulan / 230 Lot Panen)  
**Kurs Referensi Transaksi Bank Indonesia (13 Oktober 2026)**: **1 MYR = 4.384,87 IDR**  
**Dokumen Resmi PDF**: `07_EXECUTIVE_SUMMARY/executive_summary.pdf`

---

### 1. Konteks Bisnis & Tantangan Manajemen (*Business Context & Challenge*)
Tanjung Palma Agro-Industrial Estate adalah badan usaha agroindustri kelapa sawit terintegrasi yang mencakup perkebunan, transportasi armada truk, pabrik kelapa sawit (*Crude Palm Oil Mill*), laboratorium kendali mutu, dan fasilitas tangki timbun pengapalan CPO. Manajemen menghadapi tantangan strategis berupa:
1. **Tingginya Laju Penolakan TBS (*High FFB Rejection Rate*)**: Sebanyak 12,61% dari total lot buah yang dipanen ditolak saat tiba di gerbang pabrik.
2. **Keterlambatan Logistik Lapangan (*Field & Transport Delays*)**: Penumpukan antrean di kebun yang memicu risiko peningkatan Asam Lemak Bebas (*Free Fatty Acid* / FFA).
3. **Klaim Pengurangan Nilai Faktur dari Pembeli (*Sales Allowances*)**: Pemotongan harga CPO saat pengapalan akibat deviasi standar mutu minyak.

---

### 2. Metodologi Data Engineering & Validasi Integritas
Analisis dilakukan dengan menggunakan kombinasi **DuckDB SQL** untuk rekayasa data transaksi berskala tinggi dan **Celonis Process Mining** untuk visualisasi peta alur proses (*Process Discovery*) dan diagnostik antrean:
- **Pembersihan Log Transaksi**: Dari 6.325 baris awal, sebanyak **145 rekaman duplikat** dieliminasi, **1 baris korup** (`RAW-0005170`, *Buyer Remittance Matched*) dikarantina karena anomali timestamp `'not-a-time'`, dan **17 rekaman terbalik** (*start > end*) diperbaiki secara kronologis.
- **Integritas Hasil Akhir**: Menghasilkan **6.179 completed events** yang 100% valid tanpa inkonsistensi identitas finansial across seluruh **230 processing lots**.

---

### 3. Financial Baseline & Konversi IDR (Kurs Bank Indonesia 13 Oktober 2026)
Berdasarkan data harian resmi Bank Indonesia per 13 Oktober 2026:
$$\text{Kurs Jual} = 4.408,94\text{ IDR} \quad|\quad \text{Kurs Beli} = 4.360,80\text{ IDR} \quad\longrightarrow\quad \text{Reference Rate (Midpoint)} = \mathbf{4.384,87\text{ IDR per 1 MYR}}$$

#### Tabel Neraca Baseline Operasional (As-Is):
| Komponen Finansial | Nilai (MYR) | Nilai (IDR) | Proporsi / Keterangan |
|---|---|---|---|
| **Gross Recognized Revenue** | 7.095.410,76 MYR | 31.112.450.410,61 IDR | Penjualan CPO pada saat dispatch |
| **Sales Allowances (Deduction)** | -20.949,08 MYR | -91.857.117,14 IDR | Potongan denda mutu dari pembeli |
| **Net Realized Revenue** | **7.074.461,68 MYR** | **31.020.593.293,47 IDR** | Pendapatan bersih yang direalisasikan |
| **Sunk Feedstock Crop Cost** | 4.907.350,72 MYR | 21.518.095.460,91 IDR | 78,95% dari total biaya operasional |
| **Harvest Operations & Transport** | 231.493,59 MYR | 1.015.068.830,78 IDR | Operasi panen lapangan & logistik truk |
| **Milling, Lab & Storage Cost** | 1.077.201,35 MYR | 4.723.388.407,12 IDR | Pengolahan pabrik, lab, dan tangki timbun |
| **Total Operational Cost** | **6.216.045,66 MYR** | **27.256.552.698,81 IDR** | Beban pengeluaran seluruh 230 lot |
| **Net Profit Contribution** | **858.416,02 MYR** | **3.764.040.594,66 IDR** | **Margin kontribusi bersih perusahaan** |
| **Biaya Rata-rata per Lot** | **27.026,29 MYR** | **118.506.750,86 IDR** | Biaya rata-rata seluruh 230 lot |

---

### 4. Temuan Kunci Diagnostik (*Key Diagnostic Findings*)
1. **Kebocoran Biaya Masif pada Lot Ditolak (*Cost Leakage*)**:
   - Sebanyak **29 lot (12,61%)** ditolak saat inspeksi masuk pabrik.
   - Karena biaya budidaya kebun (*crop material cost* sebesar MYR 23.277 per lot) telah dikeluarkan saat panen, penolakan ini menimbulkan **kerugian kas dan aset biologis langsung sebesar 711.861,41 MYR (3,12 Miliar IDR)**.
   - Ditambah hilangnya potensi laba normal, total kerugian ekonomi mencapai **953.023,09 MYR (4,18 Miliar IDR)**.
2. **Titik Kritis Pelanggaran SLA di Tahap Kebun**:
   - Sebanyak **98,33% (177 dari 180)** pelanggaran SLA terjadi pada tahap *Plantation / Harvesting* (terutama antrean persetujuan batch dan penugasan regu panen), mengakumulasi 818 jam antrean.
3. **Bottleneck Kapasitas Pabrik di Stasiun Perebusan (*Sterilization*)**:
   - Stasiun sterilisasi menyerap durasi operasi terlama (255,8 jam) dan waktu tunggu antre terlama (38,5 jam).
   - Terjadi ketimpangan beban kerja: bejana sterilizer FAC-029 menangani 79,4% lot, sehingga ketika terjadi antrean pada unit FAC-030 dan FAC-031, waktu tunggu melonjak tajam hingga 34,6 menit per lot.
4. **Beban Rework Sah & Pemotongan Harga Komersial**:
   - Pengerjaan ulang mutu minyak (*CPO Quality Rework*) menelan biaya **MYR 18.469,49** (27 kasus), pengujian lab ulang menyerap **MYR 2.308,02** (27 kasus), dan denda pembeli memangkas pendapatan sebesar **-MYR 20.949,08** (14 kasus). Total beban mutu: **43.193,28 MYR (189,40 Juta IDR)**.

---

### 5. Evaluasi Skenario Perbaikan & Peringkat Rekomendasi
| Peringkat | Inisiatif Perbaikan | Potensi Revenue / Penghematan | Biaya Program (CAPEX + OPEX) | Net Financial Benefit (MYR) | Net Financial Benefit (IDR) | Rekomendasi Manajemen |
|---|---|---|---|---|---|---|
| **Prioritas 1** | **Peningkatan Grading Kebun di TPH (Q08)** | +162.824,89 MYR | 25.000,00 MYR | **+113.151,43 MYR** | **+496.154.378,13 IDR** | **DISETUJUI SEGERA (ROI 452,6%)** |
| **Prioritas 2** | **Stabilisasi Mutu CPO di Clarifier (Q06)** | +19.203,82 MYR | 9.500,00 MYR | **+9.703,82 MYR** | **+42.550.115,89 IDR** | **DISETUJUI SEGERA (ROI 102,1%)** |
| Pilihan 3 | Penjadwalan Armada Truk Transportasi (Q07) | +3.290,00 MYR | 7.200,00 MYR | **-3.910,00 MYR** | -17.144.841,70 IDR | Ditolak (Beban software > hemat BBM) |
| Pilihan 4 | Ekspansi Mesin Sterilisasi Baru (Q09) | 0,00 MYR | 125.000,00 MYR | **-125.000,00 MYR** | -548.108.750,00 IDR | Ditolak Keras (Idle capacity pada demand tetap) |

---

### 6. Perbandingan Skenario As-Is vs. No-Action vs. To-Be
- **Skenario As-Is & No-Action**: Laba kontribusi stagnan pada **858.416,02 MYR (3,76 Miliar IDR)** di tengah beban kebocoran lot reject sebesar 711.861 MYR per 2 tahun.
- **Skenario Rekomendasi To-Be (Portofolio Prioritas 1 + Prioritas 2)**:
  - Total Pendapatan Bersih meningkat menjadi: **7.247.761,11 MYR (31,78 Miliar IDR)**.
  - Total Biaya Operasional & Program: **6.266.489,84 MYR (27,48 Miliar IDR)**.
  - **Laba Kontribusi To-Be Melonjak Menjadi**: **981.271,27 MYR (4.302.744.888,68 IDR)**.
  - **Pertumbuhan Laba Bersih Tambahan**: **+122.855,25 MYR (+538.704.294,02 IDR)** atau **tumbuh +14,31%** di atas baseline!

---

### 7. Rencana Aksi Strategis Manajemen (*Action Plan*)
1. **Eksekusi Q1 2027**: Luncurkan program inspeksi kematangan TBS berbasis instrumen NIR portabel di TPH kebun dengan investasi modal MYR 20.000. Terapkan SOP penolakan buah mentah sebelum masuk ke bak truk.
2. **Pemasangan Sensor Otomasi Pabrik**: Pasang pengendali suhu otomatis pada stasiun pemurnian dan tangki vakum (MYR 8.000) untuk mengeliminasi penyebab klaim penalti mutu pembeli.
3. **Pengendalian Belanja Modal**: Batalkan rencana pembelian mesin perebus sterilizer baru dan software transportasi mahal; prioritaskan *load balancing* internal.
4. **Tata Kelola Risiko Lapangan**: Berlakukan bonus kualitas bagi mandor panen yang berhasil menekan reject kebun di bawah 3%, serta tetapkan batas waktu maksimal panen-ke-pabrik maksimal 3,0 jam.
