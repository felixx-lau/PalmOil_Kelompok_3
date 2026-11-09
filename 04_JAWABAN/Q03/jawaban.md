# Analisis Q03 Descriptive
## Plantation to Mill Performance

Waiting pada dataset terkonsentrasi dalam satu lonjakan di Mei 2026. Seluruh 1.047,10 jam waiting tercatat pada bulan tersebut, dengan 67 pengiriman pada 8–9 Mei; hasil agregat 24 bulan tidak cukup untuk menyebut masalah ini kronis.

### 01 Evidence and Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q06: `python3 02_SQL/export_q01_q06_results.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Gambar Celonis merupakan ilustrasi tambahan.

- **Data**: `01_DATA/cleaned/celonis_event_log_clean.csv` (6.179 event, 230 case).
- **SQL**: `02_SQL/queries_by_question/Q03.sql`.
- **Ilustrasi Celonis tambahan**: `03_CELONIS_EVIDENCE/Q03/Q03_sla_violations_by_activity.png` dan `Q03_waiting_vs_processing_by_activity.png`.
- **Hasil SQL**: `02_SQL/results/Q03_01.csv` sampai `Q03_04.csv`.

| Tahap | Event | Waiting rata-rata (menit) | Total waiting (jam) | Total processing (jam) | Pelanggaran SLA | Tingkat pelanggaran |
|---|---|---|---|---|---|---|
| Plantation / Harvesting | 1.366 | 35,93 | 818,08 | 664,05 | 177 | 12,96% |
| Transport & Logistics | 654 | 11,87 | 129,38 | 523,58 | 3 | 0,46% |
| Weighbridge & Reception | 838 | 0,33 | 4,65 | 383,45 | 0 | 0,00% |
| Milling & Processing | 2.133 | 2,07 | 73,75 | 1.805,52 | 0 | 0,00% |
| Dispatch & Finance | 1.188 | 1,07 | 21,23 | 430,63 | 0 | 0,00% |
| **Total** | **6.179** | **10,17** | **1.047,10** | **3.807,23** | **180** | **2,91%** |

Waiting dan processing adalah jumlah durasi event, bukan durasi end-to-end case atau waktu kalender perusahaan. Total dihitung sebelum pembulatan. Waiting rata-rata seluruh event = 62.826 menit / 6.179 event = 10,17 menit. Bulan waiting mengikuti `timestamp` penyelesaian event.

### 02 Descriptive Finding
1. **Konsentrasi temporal**: Seluruh waiting positif (726 event; 1.047,10 jam) berada pada Mei 2026. Bulan lain mencatat nol waiting pada kolom yang tersedia; ini tidak membuktikan tidak ada antrean yang tidak tercatat.
2. **Konsentrasi tahap**: Kebun menyumbang 818,08 jam atau 78,13% waiting, serta 177 dari 180 pelanggaran SLA (98,33%).
3. **Lonjakan pengiriman**: Berdasarkan `activity_start_time` pada `Transport to Palm Oil Mill`, terdapat 23 pengiriman pada 8 Mei dan 44 pada 9 Mei 2026, total **67 pengiriman dalam dua hari**. Ini satu episode lonjakan, bukan bukti masalah kronis.
4. **Kepatuhan SLA pabrik**: Milling dan Weighbridge mencatat nol pelanggaran SLA menurut flag yang tersedia. Nilai ini tidak membuktikan seluruh proses pabrik stabil atau bebas antrean.

### 03 Diagnostic Reasoning
Lonjakan volume bertepatan dengan konsentrasi waiting dan perlu menjadi fokus investigasi. Event log belum memastikan penyebabnya berupa koordinasi regu, prioritas operator terhadap fasilitas tertentu, atau persiapan boiler. Pemeriksaan jadwal kedatangan, kesiapan resource, serta konsistensi pencatatan `activity_ready_time` diperlukan untuk menguji penyebab.

Untuk menghindari rata-rata 24 bulan menyembunyikan beban puncak, durasi sterilisasi dibagi pada batas tengah malam. **Pada 9 Mei 2026, FAC-029 mencatat 20,63 jam processing, setara 85,97% atau sekitar 86% dari 24 jam kalender.** Penjumlahan seluruh durasi berdasarkan tanggal selesai akan menghasilkan angka berbeda karena sebagian aktivitas melewati tengah malam.

Persentase tersebut adalah beban durasi tercatat terhadap 24 jam, bukan utilisasi terhadap jam operasi efektif atau OEE. Perlu verifikasi jadwal kerja, downtime, dan interval yang tumpang tindih untuk menghitung utilisasi aktual. Persentase porsi lot, termasuk 79,4% bila digunakan dalam analisis fasilitas, tidak boleh diberi label utilisasi.

### 04 Business and Financial Implication
- Tahap kebun mencatat biaya MYR 4.973.669,70 atau 80,01% dari biaya total MYR 6.216.045,66. Besarnya biaya tahap ini tidak sama dengan kerugian akibat waiting.
- Log menunjukkan konsentrasi antrean, tetapi belum mengukur pengaruh kausalnya terhadap FFA, allowance, atau rejection. Tidak ada nilai penghematan finansial Q03 yang dapat langsung ditambahkan ke baseline **MYR 858.416,02**.
- Beban harian tinggi saat lonjakan mendukung evaluasi pengaturan kedatangan dan kapasitas pada hari puncak. Rata-rata periode penuh saja tidak cukup untuk memutuskan tambahan mesin.

### 05 As Is No Action and To Be
- **As-Is**: Satu episode lonjakan Mei memuat seluruh waiting tercatat; 67 pengiriman berlangsung pada 8–9 Mei dan beban FAC-029 mencapai sekitar 86% kalender pada 9 Mei.
- **No-Action**: Jika pola pengiriman serupa terulang dengan kondisi sama, antrean berpotensi muncul kembali. Frekuensi kejadian dan kerugian masa depan belum dapat dipastikan.
- **To-Be**: Uji penjadwalan kedatangan dan kesiapan kapasitas pada hari puncak. Gunakan penurunan waiting kebun 30% sebagai target uji, setara 245,43 jam dari baseline 818,08 jam, bukan hasil yang sudah terbukti. Pantau SLA dan penolakan pada periode volume sebanding sebelum menetapkan target permanen.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Investigasi episode 8–9 Mei, periksa distribusi waiting sepanjang Mei, dan validasi timestamp sebelum mengubah pembagian regu atau membeli kapasitas baru.
- **Risiko**: Perubahan jadwal tanpa mengetahui penyebab dapat memindahkan antrean ke tahap lain. Anomali ready time juga dapat memengaruhi interpretasi waiting.
- **Asumsi dan batasan**: Perhitungan memakai kolom waiting, processing, dan flag SLA pada CSV saat ini. Koreksi cleaning dan ekspor ulang pada bagian A perlu diikuti penghitungan ulang. Beban kalender mengasumsikan pembanding 24 jam per fasilitas per hari; tidak mengasumsikan semua jam tersedia untuk operasi.

### 07 Evidence File Paths and SQL References
- [Query Q03](../../02_SQL/queries_by_question/Q03.sql)
- [Kinerja per tahap](../../02_SQL/results/Q03_01.csv)
- [Distribusi waiting bulanan](../../02_SQL/results/Q03_02.csv)
- [Pengiriman harian](../../02_SQL/results/Q03_03.csv)
- [Beban harian sterilizer](../../02_SQL/results/Q03_04.csv)
- [Bukti SLA Celonis](../../03_CELONIS_EVIDENCE/Q03/Q03_sla_violations_by_activity.png)
- [Bukti waiting dan processing Celonis](../../03_CELONIS_EVIDENCE/Q03/Q03_waiting_vs_processing_by_activity.png)
