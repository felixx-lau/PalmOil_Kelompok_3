# Analisis Q08 · Prescriptive
## FFB Grading Improvement

### 01 Evidence & Data Source
- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q08.sql`
- **Visual Evidence**: `03_CELONIS_EVIDENCE/Q08/Q08_ffb_rejection_reduction_model.png`

#### Tabel Pemodelan Skenario Penurunan Penolakan TBS Sebesar 15%:
| Komponen Finansial & Operasional | Basis Perhitungan | Nilai (MYR) | Nilai (IDR) | Keterangan & Asumsi |
|---|---|---|---|---|
| **Volume Lot Diselamatkan** | $29\text{ lot ditolak} \times 15\%$ | **4,35 Lot** | **4,35 Lot** | Lot yang dicegah menjadi reject dan diproses jadi CPO |
| **Pendapatan Tambahan (*Incremental Revenue*)** | $4,35\text{ lot} \times 37.431,01\text{ MYR}$ | **+162.824,89** | **+713.966.575,11** | CPO dispatch sales yang berhasil direalisasikan |
| **Biaya Tanam/Bahan Baku (*Sunk Crop Cost*)** | $4,35\text{ lot} \times 23.277,27\text{ MYR}$ | **[101.256,12]** | **[443.994.922,60]** | **Sudah hangus saat panen; BUKAN biaya tambahan baru** |
| **Biaya Pengolahan Pabrik Tambahan (*Marginal Milling Cost*)** | $4,35\text{ lot} \times 5.672,06\text{ MYR}$ | **-24.673,46** | **-108.189.928,55** | Biaya uap, listrik, press, dan clarifier per lot olah |
| **Biaya Implementasi (*CAPEX*)** | Alat uji NIR portabel & modul pelatihan | **-20.000,00** | **-87.697.400,00** | Investasi awal pengadaan 4 unit scanner kematangan TBS |
| **Biaya Operasional Tambahan (*OPEX*)** | Kalibrasi tahunan & audit mutu TPH | **-5.000,00** | **-21.924.350,00** | Pemeliharaan alat & insentif mandor grading |
| **Net Financial Benefit (MYR)** | **Revenue − Mill Cost − CAPEX − OPEX** | **+113.151,43** | **+496.154.378,13** | **Laba Finansial Bersih Tambahan** |
| **Laba Kontribusi To-Be Perusahaan** | **MYR 858.416,02 + MYR 113.151,43** | **971.567,45** | **4.260.194.972,79** | **Peningkatan +13,18% dari Laba Baseline** |
| **Return on Investment (ROI)** | $\text{Net Benefit} \div \text{Total Program Cost}$ | **452,6%** | **452,6%** | Sangat layak secara investasi |

---

### 02 Descriptive Finding
1. **Dampak Penurunan 15% Rejection**: Menyelamatkan **4,35 lot TBS** yang sebelumnya dibuang percuma di gerbang pabrik menjadi produk CPO komersial.
2. **Realisasi Pendapatan Baru**: Menghasilkan tambahan penjualan kotor CPO sebesar **MYR 162.824,89** (**713,97 Juta IDR**).
3. **Hasil Finansial Bersih yang Luar Biasa**: Setelah memperhitungkan biaya pemrosesan pabrik tambahan (MYR 24.673,46) serta seluruh biaya investasi alat dan operasional (MYR 25.000,00), inisiatif ini memberikan **Net Financial Benefit sebesar +113.151,43 MYR** (**+496,15 Juta IDR**).

---

### 03 Diagnostic Reasoning (Perlakuan Khusus Sunk Cost Kelapa Sawit)
- **Kunci Keberhasilan Ekonomi Kelapa Sawit**:
  - Pada industri sawit terintegrasi, biaya agronomi (*crop production cost* sebesar MYR 23.277,27 per lot) telah **dikeluarkan dan hangus (*sunk*)** saat buah dipetik dari pohon. 
  - Jika buah tersebut ditolak di pabrik, nilai MYR 23.277 tersebut 100% musnah.
  - Namun jika buah berhasil dicegah dari pembusukan dan diolah di pabrik, perusahaan **tidak perlu mengeluarkan biaya tanam kedua**. Biaya kas keluar tambahan (*incremental cash out*) hanyalah biaya pengolahan pabrik (*marginal milling cost*) sebesar MYR 5.672,06 per lot.
  - Selisih antara harga jual CPO (MYR 37.431,01) dan biaya olah marjinal (MYR 5.672,06) menghasilkan **marjin kontribusi kotor sebesar MYR 31.758,95 per lot** yang diselamatkan!

---

### 04 Business & Financial Implication
- Program inspeksi awal di TPH (*early field grading*) membalikkan status kerugian lot dari $-24.546,95\text{ MYR}$ menjadi laba positif $+7.085,49\text{ MYR}$ per lot setelah memperhitungkan beban investasi program.
- Inisiatif ini meningkatkan total laba kontribusi perkebunan Tanjung Palma sebesar **+13,18%** hanya dengan menyelamatkan 4–5 lot dari penolakan.

---

### 05 As-Is vs No-Action vs To-Be
- **As-Is**: 29 lot ditolak dengan kerugian langsung -MYR 711.861,41.
- **No-Action**: Mempertahankan cara grading visual lama berisiko melanjutkan pembuangan 29 lot per 2 tahun.
- **To-Be**: Mengurangi penolakan sebesar 15%, mengangkat kontribusi perusahaan dari MYR 858.416,02 menjadi MYR 971.567,45.

---

### 06 Recommendation, Risk, Assumptions
- **Rekomendasi**: **Jadikan inisiatif ini sebagai PRIORITAS UTAMA (Priority 1) manajemen**. Lakukan pengadaan alat uji kematangan digital dan pelatihan standar panen di TPH kebun secepatnya.
- **Risiko**: Disiplin pemanen di lapangan; mandor panen harus diawasi agar tidak meloloskan buah mentah demi mengejar target tonase.
- **Asumsi**: Asumsi penurunan 15% adalah konservatif; kapasitas stasiun perebusan pabrik masih mencukupi untuk memproses 4,35 lot tambahan.

---

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q08.sql`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/02_SQL/queries_by_question/Q08.sql)
- **Visual Chart (Evidence)**: [`03_CELONIS_EVIDENCE/Q08/Q08_ffb_rejection_reduction_model.png`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q08/Q08_ffb_rejection_reduction_model.png)
- **Model Skenario Finansial**: [`05_FINANCIAL/scenario_comparison.csv`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/05_FINANCIAL/scenario_comparison.csv)
