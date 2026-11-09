# Analisis Q07 · Prescriptive
## FFB Transport Scheduling

### 01 Evidence & Data Source
- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q07.sql`
- **Visual Evidence**: `03_CELONIS_EVIDENCE/Q07/Q07_transport_scheduling_scenario.png`

#### Tabel Evaluasi Skenario Penurunan Waktu Tunggu Transportasi 20%:
| Parameter Skenario | Kondisi As-Is (Baseline) | Kondisi To-Be (-20% Waiting) | Delta / Penghematan | Satuan |
|---|---|---|---|---|
| **Total Waktu Tunggu Truk** | 129,38 | 103,50 | **-25,88 Jam (-1.552,6 Menit)** | Jam Operasional |
| **Rata-rata Waktu Tunggu per Rit** | 11,87 | 9,50 | **-2,37 Menit** | Menit / Rit |
| **Biaya Armada Transportasi** | 165.174,61 | 161.884,61 | -3.290,00 | MYR |
| **Porsi Biaya Dapat Dihindari (*Avoidable Share*)** | — | 12,0% | 3.290,00 | MYR (BBM Idle & Wear) |
| **Biaya Implementasi Sistem (*CAPEX*)** | 0,00 | 6.000,00 | -6.000,00 | MYR (Sistem Dispatch Mobile) |
| **Biaya Operasional Tambahan (*OPEX*)** | 0,00 | 1.200,00 | -1.200,00 | MYR / Horizon |
| **Net Financial Benefit (MYR)** | **0,00** | **-3.910,00** | **-3.910,00** | **MYR** |
| **Net Financial Benefit (IDR)** | **0,00** | **-17.144.841,70** | **-17.144.841,70** | **IDR** |
| **Total Laba Kontribusi Perusahaan** | **858.416,02** | **854.506,02** | **-3.910,00** | **MYR** |

---

### 02 Descriptive Finding
1. **Baseline Transportasi**: Seluruh 218 pengangkutan TBS dari kebun ke pabrik mengakumulasi waktu tunggu sebesar **129,38 jam** (7.763 menit) dengan rata-rata 11,87 menit per rit.
2. **Hasil Penurunan 20%**: Penjadwalan transportasi berhasil memangkas **25,88 jam** waktu tunggu idle truk (setara dengan 7,1 menit penghematan pada aktivitas pemuatan dan antrean masuk pabrik).
3. **Hasil Finansial Bersih**: Karena biaya implementasi sistem (MYR 6.000,00) dan biaya operasional server/data (MYR 1.200,00) lebih besar daripada penghematan biaya bahan bakar idle yang realistis (MYR 3.290,00), skenario ini menghasilkan **Net Financial Benefit negatif sebesar -3.910,00 MYR** (**-17,14 Juta IDR**).

---

### 03 Diagnostic Reasoning
#### Klasifikasi Manfaat: Waktu vs. Biaya vs. Kualitas
- **Manfaat Waktu (*Time Benefit*)**: **TERBUKTI**. Pengurangan 25,88 jam antrean truk secara nyata meningkatkan ketersediaan rotasi armada (*truck turnaround time*).
- **Manfaat Biaya yang Dapat Dihindari (*Avoidable Cost*)**: **SANGAT TERBATAS**. Pengemudi truk di Tanjung Palma adalah pekerja bulanan tetap (*fixed monthly labor*), dan armada truk dimiliki/disewa secara jangka panjang. Pengurangan waktu tunggu tidak otomatis memangkas gaji pokok pengemudi. Hanya komponen konsumsi bahan bakar saat mesin menyala diam (*engine idling*) dan keausan minor (diestimasi 12% dari total biaya alat) yang merupakan penghematan tunai riil (*cash savings*).
- **Manfaat Mutu (*Quality Benefit*)**: **TIDAK DAPAT DIASUMSIKAN**. Sesuai batasan panduan analisis (*"hindari asumsi kualitas membaik tanpa indikator"*), penghematan antrean rata-rata sebesar 2–7 menit per rit tidak signifikan secara biologis terhadap akumulasi asam lemak bebas (FFA) jika dibandingkan dengan total durasi transit 3–4 jam.

---

### 04 Business & Financial Implication
- Mengimplementasikan software penjadwalan truk secara mandiri tanpa integrasi program lain justru **menurunkan profit contribution perusahaan dari MYR 858.416,02 menjadi MYR 854.506,02**.
- Manajemen kelapa sawit tidak boleh tergiur oleh jargon digitalisasi logistik jika penghematan biaya riil tidak mampu menutup biaya lisensi dan pemeliharaan teknologi.

---

### 05 As-Is vs No-Action vs To-Be
- **As-Is**: Pengemudi truk mengantre di TPH dan ramp timbang rata-rata 11,87 menit tanpa sistem penjadwalan formal.
- **No-Action**: Mempertahankan kondisi As-Is tidak menambah biaya modal baru (*zero capex*). Mengingat antrean truk hanya menyumbang 12,3% dari total antrean kebun, No-Action lebih menguntungkan secara finansial daripada menerapkan sistem berbayar mandiri.
- **To-Be**: Terapkan penjadwalan berbasis prosedur operasional standar internal (SOP radio komunikasi / WhatsApp dispatch sederhana) tanpa membeli software mahal pihak ketiga.

---

### 06 Recommendation, Risk, Assumptions
- **Rekomendasi**: Jangan menyetujui pengadaan perangkat lunak penjadwalan armada truk berbayar secara terpisah. Alihkan anggaran ke program inspeksi mutu buah di kebun (Q08).
- **Risiko**: Kepadatan lalu lintas truk di jembatan timbang pada puncak musim panen (*peak crop season*).
- **Asumsi**: Porsi biaya yang benar-benar dapat dihemat (*avoidable share*) dari waktu tunggu truk adalah 12% dari komponen peralatan/BBM.

---

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q07.sql`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/02_SQL/queries_by_question/Q07.sql)
- **Visual Chart (Evidence)**: [`03_CELONIS_EVIDENCE/Q07/Q07_transport_scheduling_scenario.png`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q07/Q07_transport_scheduling_scenario.png)
- **Tabel Skenario**: [`05_FINANCIAL/scenario_comparison.csv`](file:///Users/felix/Desktop/Semester%204/Process%20Mining/UAS%20Process%20Mining/24SI1_Group03_Palm_Oil/05_FINANCIAL/scenario_comparison.csv)
