# Analisis Q06 · Diagnostic
## Quality Rework and Allowances

### 01 Evidence & Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q06: `python3 02_SQL/export_q01_q06_results.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Gambar Celonis merupakan ilustrasi tambahan.

- **Sumber Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`
- **Query Eksekusi**: `02_SQL/queries_by_question/Q06.sql`
- **Ilustrasi tambahan**: `03_CELONIS_EVIDENCE/Q06/Q06_rework_and_allowance_summary.png`

#### Tabel 1: Biaya Rework Operasional yang Tercatat (*Recorded Rework Cost*):
| Aktivitas Rework Sah | Penanda Rework (*rework_flag*) | Frekuensi Eksekusi | Total Biaya Tenaga Kerja (MYR) | Total Biaya Bahan & Kimia (MYR) | Total Biaya Alat/Mesin (MYR) | Total Biaya Overhead (MYR) | Total Biaya Rework (MYR) | Rata-rata Biaya per Kasus (MYR) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **CPO Quality Rework Applied** | False (Aktivitas Rework) | 27 | 1.080,49 | 13.007,56 | 3.592,90 | 788,54 | **18.469,49** | 684,06 |
| **CPO Laboratory Tested** | **True** (Uji Ulang Lab) | 27 | 848,99 | 0,00 | 735,32 | 723,71 | **2.308,02** | 85,48 |
| **FFB Field Grading** | **True** (Grading Ulang Kebun) | 22 | 407,55 | 0,00 | 128,00 | 510,13 | **1.045,68** | 47,53 |
| **Total Beban Rework Operasional** | — | **76** | **2.337,03** | **13.007,56** | **4.456,22** | **2.022,38** | **21.823,19** | **287,15** |

#### Tabel 2: Penyesuaian Penjualan Komersial (*Authorized Sales Allowances*):
| Aktivitas Penyesuaian | Frekuensi Kasus | Total Pengurangan Pendapatan (MYR) | Biaya Administrasi Penyesuaian (MYR) | Total Dampak Negatif Kontribusi (MYR) |
| --- | --- | --- | --- | --- |
| **Authorized CPO Sales Allowance** | 14 Lot | **-20.949,08** | **421,01** | **-21.370,09** |

---

### 02 Descriptive Finding
1. **Total Beban Kualitas Gagal**: Akumulasi biaya rework operasional ditambah penalti komersial mencapai **43.193,28 MYR** (**189,40 Juta IDR**).
2. **Biaya Rework Terbesar**: `CPO Quality Rework Applied` (27 kasus) memakan biaya terbesar (**MYR 18.469,49**), berdasarkan penjumlahan komponen biaya event. Jenis tindakan teknis spesifik belum dapat dipastikan dari nama aktivitas saja.
3. **Uji Ulang Laboratorium**: Sebanyak 27 lot membutuhkan pengujian lab kedua (`CPO Laboratory Tested` dengan `rework_flag = true`) setelah perbaikan mutu minyak selesai dilakukan, menghabiskan biaya MYR 2.308,02.
4. **Grading Ulang di Kebun**: Sebanyak 22 lot mengalami grading ulang di TPH dengan biaya MYR 1.045,68.
5. **Penalti Penjualan CPO**: Sebanyak 14 lot mengalami pemotongan nilai faktur akibat klaim mutu dari pembeli (*buyer allowances*) sebesar -MYR 20.949,08.

---

### 03 Diagnostic Reasoning
Rework diidentifikasi oleh DuckDB dengan `rework_flag = true OR activity ILIKE '%rework%'`. Kedua kondisi diperlukan: `CPO Quality Rework Applied` memiliki flag false tetapi merupakan aktivitas rework yang tercatat. Jika hanya menggunakan flag, biaya MYR 18.469,49 akan terlewat.

Grading ulang dan retest merupakan eksekusi dengan identitas dan waktu tersendiri yang dipertahankan pada data bersih. Pembersihan menghapus 145 baris duplikat ekstraksi; pengulangan nama aktivitas saja bukan dasar menghapus event. Untuk audit rework, periksa event_id, waktu, urutan, resource, dan biaya agar eksekusi sah tidak terhapus sebagai duplikat.

Log membuktikan biaya rework dan allowance, tetapi belum memastikan deviasi suhu, bahan kimia, atau parameter mutu tertentu sebagai penyebab. Alasan tindakan korektif, hasil laboratorium, dan kontrak pembeli diperlukan untuk menguji mekanismenya.

### 04 Business & Financial Implication
- Setiap lot yang membutuhkan pengerjaan ulang mutu CPO menelan biaya tambahan sebesar **MYR 769,54 per lot** (rework + retest).
- Sebanyak 14 lot yang lolos ke pembeli namun masih terkena penalti potongan harga (*sales allowance*) rata-rata menderita pemotongan nilai sebesar **MYR 1.496,36 per lot**, menggerus margin keuntungan bersih transaksi.

---

### 05 As Is No Action and To Be
- **As-Is**: 27 dari 189 lot olah (14,29%) membutuhkan rework mutu CPO, dan 14 dari 189 lot (7,41%) memiliki allowance. Beban rework MYR 21.823,19 ditambah penurunan revenue MYR 20.949,08 serta administrasi MYR 421,01 menghasilkan total MYR 43.193,28 pada horizon 24 bulan. Beban ini sudah masuk baseline kontribusi.
- **No-Action**: Pada komposisi lot dan kondisi yang sama, beban dapat berulang; angka 24 bulan tidak boleh disebut kerugian tahunan tanpa normalisasi dan bukti pola waktu.
- **To-Be**: Mengikuti asumsi portofolio Q10, uji penurunan allowance 50% dan biaya rework operasional 40%. Pemulihan revenue = 50% × MYR 20.949,08 = MYR 10.474,54; penghematan rework = 40% × MYR 21.823,19 = MYR 8.729,28 setelah pembulatan. Manfaat kotor MYR 19.203,82 dikurangi implementasi MYR 8.000,00 dan OPEX MYR 1.500,00 menghasilkan **manfaat bersih MYR 9.703,82** pada horizon model yang sama. Biaya administrasi allowance tidak dimasukkan sebagai penghematan tambahan. **Sensitivitas**: jika allowance tidak turun sama sekali, net benefit = -MYR 770,72; net benefit baru positif bila allowance turun lebih dari ±3,68% (`05_FINANCIAL/sensitivity.csv`). Angka ini adalah skenario, bukan hasil pilot. Pengurangan 40% mencakup seluruh biaya rework teridentifikasi, termasuk grading kebun; kelayakan cakupan intervensi harus diuji agar manfaatnya tidak tumpang tindih dengan Q08.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Telusuri parameter proses yang berkaitan dengan rework dan klaim pembeli, kemudian uji stabilisasi proses dengan kontrol mutu tetap berjalan.
- **Risiko**: Penghapusan retest semata-mata untuk menekan biaya dapat melemahkan deteksi mutu. Penurunan rework tidak otomatis menurunkan allowance dengan proporsi yang sama.
- **Asumsi**: Allowance merupakan pengurangan revenue yang sah. Model mengasumsikan biaya rework dapat dihindari secara proporsional 40% dan allowance 50%; biaya intervensi dan kelayakannya perlu diverifikasi.

### 07 Evidence File Paths / SQL References
- **SQL Analysis Script**: [`02_SQL/queries_by_question/Q06.sql`](../../02_SQL/queries_by_question/Q06.sql)
- **Visual Chart (Evidence)**: [`03_CELONIS_EVIDENCE/Q06/Q06_rework_and_allowance_summary.png`](../../03_CELONIS_EVIDENCE/Q06/Q06_rework_and_allowance_summary.png)


Hasil DuckDB yang mendasari tabel:

- [Hasil query 1](../../02_SQL/results/Q06_01.csv)
- [Hasil query 2](../../02_SQL/results/Q06_02.csv)
- [Hasil query 3](../../02_SQL/results/Q06_03.csv)
