# Analisis Q10 · Prescriptive
## Estate-to-Mill Business Case

### 01 Evidence & Data Source
- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`, `05_FINANCIAL/exchange_rate.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q10.sql`
- **Visual Evidence**: `03_CELONIS_EVIDENCE/Q10/Q10_business_case_ranking_myr_idr.png`
- **Kurs Bank Indonesia (13 Oktober 2026)**: **1 MYR = 4.384,87 IDR**

#### Tabel 1: Peringkat Prioritas Perbaikan Proses Bisnis (*Process Improvement Ranking*):
| Peringkat Prioritas | Program Perbaikan Proses | Potensi Penghematan / Revenue Baru (MYR) | Biaya Implementasi CAPEX (MYR) | Biaya Operasional OPEX & Olah (MYR) | Net Financial Benefit (MYR) | Net Financial Benefit (IDR) | Kemudahan Implementasi (*Implementability*) | Tingkat Risiko |
|---|---|---|---|---|---|---|---|---|
| **Prioritas 1 (P1)** | **Peningkatan Grading Kebun (Q08)** | +162.824,89 | 20.000,00 | 29.673,46 | **+113.151,43** | **+496.154.378,13** | **Sangat Tinggi** | Rendah |
| **Prioritas 2 (P2)** | **Stabilisasi Mutu CPO & Pengurangan Diskon (Q06)** | +19.203,82 | 8.000,00 | 1.500,00 | **+9.703,82** | **+42.550.115,89** | **Tinggi** | Sangat Rendah |
| **Pilihan 3** | Penjadwalan Armada Truk Transportasi (Q07) | +3.290,00 | 6.000,00 | 1.200,00 | **-3.910,00** | -17.144.841,70 | Sedang | Rendah |
| **Pilihan 4** | Investasi Kapasitas Mesin Sterilisasi (Q09) | 0,00 | 110.000,00 | 15.000,00 | **-125.000,00** | -548.108.750,00 | Rendah (Konstruksi) | Sangat Tinggi |

#### Tabel 2: Perbandingan Menyeluruh No-Action vs. To-Be:
| Indikator Finansial Utama | Kondisi As-Is (Baseline) | Skenario No-Action (Status Quo) | Rekomendasi To-Be (Portofolio P1 + P2) | Pertumbuhan / Dampak Finansial Bersih |
|---|---|---|---|---|
| **Pendapatan Bersih (MYR)** | 7.074.461,68 | 7.074.461,68 | **7.247.761,11** | **+173.299,43 MYR** |
| **Pendapatan Bersih (IDR)** | 31.020.593.293,47 | 31.020.593.293,47 | **31.780.487.042,82** | **+759.893.749,35 IDR** |
| **Biaya Operasional (MYR)** | 6.216.045,66 | 6.216.045,66 | **6.266.489,84** | **+50.444,18 MYR** |
| **Biaya Operasional (IDR)** | 27.256.552.698,81 | 27.256.552.698,81 | **27.477.743.265,51** | **+221.190.566,70 IDR** |
| **Profit Contribution (MYR)** | **858.416,02** | **858.416,02** | **981.271,27** | **+122.855,25 MYR (+14,31%)** |
| **Profit Contribution (IDR)** | **3.764.040.594,66** | **3.764.040.594,66** | **4.302.744.888,68** | **+538.704.294,02 IDR (+14,31%)** |

---

### 02 Descriptive Finding
1. **Dua Program Unggulan Terbaik**:
   - **Prioritas 1: FFB Early Grading Improvement (Q08)** memberikan manfaat finansial terbesar dengan Net Benefit sebesar **+113.151,43 MYR** (**+496,15 Juta IDR**).
   - **Prioritas 2: CPO Quality Retesting & Sales Allowance Mitigation (Q06)** memberikan Net Benefit sebesar **+9.703,82 MYR** (**+42,55 Juta IDR**).
2. **Kombinasi Portofolio Rekomendasi**: Menghasilkan total manfaat finansial bersih sebesar **+122.855,25 MYR** (**+538,70 Juta IDR**).
3. **Peningkatan Profit Contribution**: Mengerek total laba kontribusi perkebunan Tanjung Palma dari MYR 858.416,02 menjadi **MYR 981.271,27**, atau melonjak sebesar **+14,31%**.

---

### 03 Diagnostic Reasoning
- Mengapa P1 dan P2 mengungguli P3 dan P4?
  - **P1 (Grading)** secara langsung memulihkan *sunk cost* bahan baku yang bernilai paling tinggi di neraca perusahaan. Dengan biaya implementasi yang sangat rendah (MYR 20.000), program ini merekrut kembali nilai ekonomi buah yang sebelumnya dibuang percuma.
  - **P2 (Quality Stabilization)** menutup kebocoran ganda: biaya uji ulang laboratorium internal dan pemotongan faktur komersial (*allowance penalties*) oleh pembeli.
  - Sebaliknya, **P3 (Transport)** tidak menghasilkan penghematan kas nyata karena struktur gaji supir truk bersifat tetap, dan **P4 (Sterilization CAPEX)** memicu pemborosan modal besar karena tidak ada pertambahan kuota panen di kebun.

---

### 04 Business & Financial Implication
- Eksekusi portofolio To-Be membutuhkan total modal kerja (*total project investment*) sebesar **MYR 28.000,00** (IDR 122.776.360,00), yang langsung terbayar kembali (*payback period*) dalam waktu **kurang dari 6 bulan** operasional.
- Risiko *cash flow* sangat minim karena 80% dari manfaat finansial berasal dari penerimaan kas penjualan CPO tambahan.

---

### 05 As-Is vs No-Action vs To-Be
- **As-Is**: Perusahaan beroperasi dengan laba kontribusi sebesar MYR 858.416,02 di tengah kebocoran biaya reject buah sebesar MYR 711.861,41 dan denda kualitas sebesar MYR 21.370,09.
- **No-Action**: Mempertahankan status quo berarti membiarkan modal kerja tergerus rutin sebesar ~3,2 Miliar IDR per siklus tanpa ada upaya pemulihan.
- **To-Be**: Dengan menjalankan Prioritas 1 dan Prioritas 2, perusahaan merealisasikan laba bersih tambahan sebesar **+538,70 Juta IDR**, menjadikan operasional Tanjung Palma jauh lebih tangguh dan efisien.

---

### 06 Recommendation, Risk, Assumptions
- **Rekomendasi Eksekutif**:
  1. Setujui implementasi **Prioritas 1 (FFB Grading Mobile Kit & Training)** dengan anggaran modal MYR 20.000,00 secepatnya pada Q1 2027.
  2. Setujui implementasi **Prioritas 2 (Sensor Otomasi Suhu Clarifier & Vacuum Tank)** dengan anggaran MYR 8.000,00.
  3. Batalkan rencana ekspansi fisik mesin sterilizer (P4) dan pengadaan software dispatch truk berbayar (P3).
- **Risiko & Mitigasi**:
  - *Risiko Adopsi Mandor*: Terapkan insentif bagi mandor yang berhasil menjaga tingkat penolakan TPH di bawah 5%.
- **Asumsi**: Kurs referensi Bank Indonesia 13 Oktober 2026 (1 MYR = 4.384,87 IDR) bersifat konstan untuk proyeksi analytical translation 2026–2028.

---

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q10.sql`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/02_SQL/queries_by_question/Q10.sql)
- **Visual Chart (Evidence)**: [`03_CELONIS_EVIDENCE/Q10/Q10_business_case_ranking_myr_idr.png`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q10/Q10_business_case_ranking_myr_idr.png)
- **Model Pembanding Finansial**: [`05_FINANCIAL/scenario_comparison.csv`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/05_FINANCIAL/scenario_comparison.csv)
