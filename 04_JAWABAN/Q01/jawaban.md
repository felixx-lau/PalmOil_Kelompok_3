# Analisis Q01 Descriptive
## Harvest to CPO Process Discovery

Analisis DuckDB atas 230 lot menunjukkan tiga varian terbesar dengan 61, 23, dan 17 case. Varian adalah kelompok lot dengan urutan aktivitas tercatat yang persis sama, bukan jenis produk. Varian 3 memiliki throughput lebih singkat daripada Varian 1, tetapi data belum membuktikan penyebabnya; perbedaan paparan periode lonjakan perlu diperhitungkan.

### 01 Evidence and Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q06: `python3 02_SQL/export_q01_q06_results.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Gambar Celonis merupakan ilustrasi tambahan.

- **Data**: `01_DATA/cleaned/celonis_event_log_clean.csv` (6.179 event, 230 case).
- **SQL**: `02_SQL/queries_by_question/Q01.sql`.
- **Ilustrasi Celonis tambahan**: `03_CELONIS_EVIDENCE/Q01/Q01_variant_list_top3.png`, `Q01_variant1_happy_path_part1.png`, dan `Q01_variant1_happy_path_part2.png`.
- **Hasil SQL**: `02_SQL/results/Q01_01.csv` untuk profil varian dan `Q01_02.csv` untuk perbandingan periode.

**Acuan analisis Q01 adalah DuckDB**, dengan urutan `timestamp, event_id` yang konsisten. Seluruh volume, waktu, dan nilai finansial di bawah memakai kelompok DuckDB. Screenshot Celonis lama menampilkan 62/23/17 case; hasilnya berbeda satu case pada varian terbesar. Timestamp yang sama dapat memengaruhi pengelompokan urutan; penyebab selisih perlu dicocokkan pada case terkait dan tidak dianggap sudah terbukti. Celonis hanya ilustrasi tambahan.

| Varian | Karakteristik | Case DuckDB | Proporsi SQL | Throughput SQL rata-rata (jam) |
|---|---|---|---|---|
| 1 | Jalur lengkap hingga dispatch dan penyelesaian administrasi | 61 | 26,52% | 19,76 |
| 2 | Penolakan saat penerimaan mill | 23 | 10,00% | 8,44 |
| 3 | Urutan alternatif dengan kumpulan activity sama dengan Varian 1 | 17 | 7,39% | 17,13 |

| Varian SQL | Biaya rata-rata (MYR/lot) | Revenue rata-rata (MYR/lot) | Kontribusi rata-rata (MYR/lot) | Total kontribusi (MYR) |
|---|---|---|---|---|
| 1 | 28.263,59 | 37.284,23 | +9.020,64 | +550.259,10 |
| 2 | 23.914,16 | 0,00 | −23.914,16 | −550.025,75 |
| 3 | 28.286,01 | 37.556,96 | +9.270,96 | +157.606,30 |

Total kontribusi dihitung langsung dari penjumlahan event, bukan perkalian rata-rata yang telah dibulatkan dengan jumlah lot. Baseline seluruh 230 case tetap **MYR 858.416,02**.

### 02 Descriptive Finding
1. Varian 1 merupakan jalur SQL terbesar: 61 dari 230 lot, dengan throughput rata-rata 19,76 jam.
2. Varian 2 mencakup 23 lot yang ditolak saat penerimaan mill. Ini hanya satu varian penolakan; total outcome ditolak di seluruh varian tetap 29 lot.
3. Varian 3 rata-rata lebih cepat 2,63 jam (17,13 vs 19,76 jam). Kumpulan activity-nya sama dengan Varian 1; perbedaan urutan tidak membuktikan peningkatan efisiensi karena paralelisasi.

#### Urutan aktivitas lengkap tiga varian terbesar

Nomor menunjukkan urutan event penyelesaian yang tersimpan, bukan bukti bahwa seluruh pekerjaan fisik berlangsung berurutan tanpa tumpang tindih. Throughput dihitung dari timestamp event pertama sampai terakhir, sehingga tidak sama dengan total durasi kerja dan tidak mencakup durasi sebelum event pertama selesai. TBS adalah tandan buah segar, FFB adalah istilah Inggris untuk TBS, CPO adalah minyak sawit mentah, dan kernel adalah inti sawit.

#### Varian 1 Jalur lengkap sampai penutupan lot

Terdapat **61 lot** dengan **30 aktivitas per lot**.

1. **Harvest Batch Created** — Membuat identitas batch atau lot panen untuk pelacakan proses.
2. **Harvest Plan Approved** — Menyetujui rencana panen sebelum pelaksanaan.
3. **Field Team Assigned** — Menetapkan tim lapangan yang menangani pekerjaan.
4. **Harvest Collection Dispatched** — Mengirim penugasan pengumpulan hasil panen.
5. **Palm Ripeness Assessed** — Memeriksa tingkat kematangan buah di kebun.
6. **FFB Harvested** — Memanen tandan buah segar atau TBS dari pohon.
7. **FFB Field Grading** — Menilai dan mengelompokkan mutu TBS di lapangan.
8. **FFB Loaded for Transport** — Memuat TBS ke kendaraan angkut.
9. **Transport to Palm Oil Mill** — Mengangkut TBS dari kebun menuju pabrik sawit.
10. **Mill Weighbridge Inbound** — Menimbang kendaraan dan muatan saat masuk pabrik.
11. **Incoming FFB Quality Inspection** — Memeriksa mutu TBS yang datang untuk keputusan penerimaan.
12. **FFB Receipt Accepted** — Mencatat penerimaan lot yang dinyatakan diterima.
13. **Steam and Boiler Readiness Checked** — Memeriksa kesiapan uap dan boiler sebelum sterilisasi.
14. **FFB Unloaded at Sterilizer Ramp** — Membongkar TBS di ramp menuju stasiun sterilisasi.
15. **FFB Sterilization Completed** — Menyelesaikan perebusan atau sterilisasi TBS.
16. **FFB Threshing Completed** — Menyelesaikan perontokan buah dari tandan.
17. **Fruit Digestion Completed** — Menyelesaikan pelumatan buah sebelum pengepresan.
18. **Crude Oil Pressing Completed** — Menyelesaikan pengepresan untuk memperoleh minyak kasar.
19. **Kernel Separation Completed** — Menyelesaikan pemisahan kernel atau inti sawit pada jalur hasil samping.
20. **Oil Clarification Completed** — Menyelesaikan klarifikasi untuk memisahkan minyak dari campuran pengotor.
21. **Kernel Drying Completed** — Menyelesaikan pengeringan kernel pada jalur hasil samping.
22. **Oil Purification Completed** — Menyelesaikan pemurnian minyak sebelum pemeriksaan mutu.
23. **CPO Laboratory Tested** — Menguji mutu CPO di laboratorium.
24. **CPO Storage Tank Updated** — Memperbarui catatan CPO pada tangki penyimpanan.
25. **CPO Transfer Authorized** — Memberikan otorisasi pemindahan CPO untuk pengiriman.
26. **CPO Loaded for Dispatch** — Memuat CPO ke sarana pengiriman.
27. **CPO Dispatch Confirmed** — Mengonfirmasi pengiriman CPO; revenue dialokasikan pada event ini dalam dataset.
28. **CPO Sales Invoice Issued** — Menerbitkan faktur penjualan CPO.
29. **Buyer Remittance Matched** — Mencocokkan pembayaran pembeli dengan transaksi penjualan.
30. **Harvest Lot Closed** — Menutup lot setelah rangkaian proses dan administrasinya selesai.

**Dampak bagi perusahaan:** Jalur ini membawa TBS sampai pengiriman dan penyelesaian administrasi penjualan. Rata-rata throughput 19,76 jam, biaya MYR 28.263,59 per lot, dan revenue MYR 37.284,23 per lot, menghasilkan kontribusi MYR 9.020,64 per lot atau total MYR 550.259,10. Jalur ini dapat menjadi acuan perbandingan karena paling banyak terjadi, tetapi frekuensi terbesar tidak membuktikan bahwa jalur ini paling efisien. Tidak ada rework atau allowance dalam trace ini; inspeksi dan uji lab tetap menjadi kontrol mutu.

#### Varian 2 Penolakan saat penerimaan pabrik

Terdapat **23 lot** dengan **13 aktivitas per lot**.

1. **Harvest Batch Created** — Membuat identitas batch atau lot panen untuk pelacakan proses.
2. **Harvest Plan Approved** — Menyetujui rencana panen sebelum pelaksanaan.
3. **Field Team Assigned** — Menetapkan tim lapangan yang menangani pekerjaan.
4. **Harvest Collection Dispatched** — Mengirim penugasan pengumpulan hasil panen.
5. **Palm Ripeness Assessed** — Memeriksa tingkat kematangan buah di kebun.
6. **FFB Harvested** — Memanen tandan buah segar atau TBS dari pohon.
7. **FFB Field Grading** — Menilai dan mengelompokkan mutu TBS di lapangan.
8. **FFB Loaded for Transport** — Memuat TBS ke kendaraan angkut.
9. **Transport to Palm Oil Mill** — Mengangkut TBS dari kebun menuju pabrik sawit.
10. **Mill Weighbridge Inbound** — Menimbang kendaraan dan muatan saat masuk pabrik.
11. **Incoming FFB Quality Inspection** — Memeriksa mutu TBS yang datang untuk keputusan penerimaan.
12. **FFB Lot Rejected** — Mencatat penolakan lot pada penerimaan pabrik; lot tidak melanjutkan pengolahan CPO dalam trace ini.
13. **Harvest Lot Closed** — Menutup lot setelah rangkaian proses dan administrasinya selesai.

**Dampak bagi perusahaan:** Setelah panen, grading, pemuatan, transportasi, penimbangan, dan inspeksi, lot ditolak lalu ditutup. Tidak ada sterilisasi, produksi CPO, dispatch, faktur, atau pencocokan pembayaran pada trace ini. Total biaya MYR 550.025,75 dan revenue nol membuat kontribusinya −MYR 550.025,75, rata-rata −MYR 23.914,16 per lot. Throughput 8,44 jam tampak singkat karena proses berhenti lebih awal; ini bukan bukti efisiensi. Sebanyak 23 lot ini merupakan 79,31% dari seluruh 29 lot reject, sehingga merupakan kelompok penting untuk investigasi pencegahan reject. Biaya panen dan transportasi sudah tercatat sebelum penolakan; seluruh biaya tersebut tidak otomatis bisa dihemat dengan memajukan inspeksi.

#### Varian 3 Jalur lengkap dengan urutan minyak dan kernel berbeda

Terdapat **17 lot** dengan **30 aktivitas per lot**.

1. **Harvest Batch Created** — Membuat identitas batch atau lot panen untuk pelacakan proses.
2. **Harvest Plan Approved** — Menyetujui rencana panen sebelum pelaksanaan.
3. **Field Team Assigned** — Menetapkan tim lapangan yang menangani pekerjaan.
4. **Harvest Collection Dispatched** — Mengirim penugasan pengumpulan hasil panen.
5. **Palm Ripeness Assessed** — Memeriksa tingkat kematangan buah di kebun.
6. **FFB Harvested** — Memanen tandan buah segar atau TBS dari pohon.
7. **FFB Field Grading** — Menilai dan mengelompokkan mutu TBS di lapangan.
8. **FFB Loaded for Transport** — Memuat TBS ke kendaraan angkut.
9. **Transport to Palm Oil Mill** — Mengangkut TBS dari kebun menuju pabrik sawit.
10. **Mill Weighbridge Inbound** — Menimbang kendaraan dan muatan saat masuk pabrik.
11. **Incoming FFB Quality Inspection** — Memeriksa mutu TBS yang datang untuk keputusan penerimaan.
12. **FFB Receipt Accepted** — Mencatat penerimaan lot yang dinyatakan diterima.
13. **Steam and Boiler Readiness Checked** — Memeriksa kesiapan uap dan boiler sebelum sterilisasi.
14. **FFB Unloaded at Sterilizer Ramp** — Membongkar TBS di ramp menuju stasiun sterilisasi.
15. **FFB Sterilization Completed** — Menyelesaikan perebusan atau sterilisasi TBS.
16. **FFB Threshing Completed** — Menyelesaikan perontokan buah dari tandan.
17. **Fruit Digestion Completed** — Menyelesaikan pelumatan buah sebelum pengepresan.
18. **Crude Oil Pressing Completed** — Menyelesaikan pengepresan untuk memperoleh minyak kasar.
19. **Oil Clarification Completed** — Menyelesaikan klarifikasi untuk memisahkan minyak dari campuran pengotor.
20. **Kernel Separation Completed** — Menyelesaikan pemisahan kernel atau inti sawit pada jalur hasil samping.
21. **Oil Purification Completed** — Menyelesaikan pemurnian minyak sebelum pemeriksaan mutu.
22. **Kernel Drying Completed** — Menyelesaikan pengeringan kernel pada jalur hasil samping.
23. **CPO Laboratory Tested** — Menguji mutu CPO di laboratorium.
24. **CPO Storage Tank Updated** — Memperbarui catatan CPO pada tangki penyimpanan.
25. **CPO Transfer Authorized** — Memberikan otorisasi pemindahan CPO untuk pengiriman.
26. **CPO Loaded for Dispatch** — Memuat CPO ke sarana pengiriman.
27. **CPO Dispatch Confirmed** — Mengonfirmasi pengiriman CPO; revenue dialokasikan pada event ini dalam dataset.
28. **CPO Sales Invoice Issued** — Menerbitkan faktur penjualan CPO.
29. **Buyer Remittance Matched** — Mencocokkan pembayaran pembeli dengan transaksi penjualan.
30. **Harvest Lot Closed** — Menutup lot setelah rangkaian proses dan administrasinya selesai.

**Dampak bagi perusahaan:** Jumlah aktivitas dan hasil akhir sama dengan Varian 1. Setelah pressing, urutan pada Varian 1 adalah kernel separation → oil clarification → kernel drying → oil purification; Varian 3 mencatat oil clarification → kernel separation → oil purification → kernel drying. Tidak ada aktivitas yang dihilangkan. Rata-rata throughput 17,13 jam atau 2,63 jam lebih singkat, biaya MYR 28.286,01 per lot, dan revenue MYR 37.556,96 per lot. Kontribusi rata-rata MYR 9.270,96 per lot, total MYR 157.606,30. Selisih kontribusi rata-rata terhadap Varian 1 adalah +MYR 250,32 per lot, dengan biaya justru +MYR 22,42 per lot; selisih ini tidak boleh disebut penghematan akibat perubahan urutan. Perbedaan periode dan karakteristik lot perlu dikendalikan sebelum menjadikan urutan ini standar.

Tiga varian ini mencakup **101 dari 230 lot atau 43,91%**. Sebanyak **129 lot atau 56,09%** mengikuti varian lain, termasuk pembatalan, grading ulang, rework mutu, dan urutan alternatif lain. Karena itu, tiga varian terbesar tidak mewakili seluruh alur. Gabungan kontribusinya **MYR 157.839,65**, sedangkan baseline seluruh lot tetap MYR 858.416,02.

### 03 Diagnostic Reasoning
| Kelompok SQL | Lot dalam jendela 25 April–31 Mei 2026 | Total lot | Porsi dalam jendela |
|---|---|---|---|
| Varian 1 | 26 | 61 | 42,62% |
| Varian 3 | 4 | 17 | 23,53% |

Jendela ditentukan dari waktu event pertama setiap case (`case_start`). Varian 1 lebih banyak terpapar periode lonjakan. Karena itu, selisih throughput **kemungkinan berkaitan dengan periode pemrosesan**, dan belum dapat diatribusikan pada paralelisasi. Perbandingan dalam periode yang setara diperlukan sebelum mengubah standar alur.

Kegagalan deteksi kualitas di kebun, termasuk kemungkinan buah mentah atau busuk tetap dipanen dan diangkut, merupakan **hipotesis** untuk penolakan. Event log tidak cukup untuk memastikan kondisi buah atau keputusan petugas pada setiap lot; perlu catatan inspeksi dan alasan penolakan.

### 04 Business and Financial Implication
- Varian 2 mencatat biaya MYR 550.025,75 tanpa revenue, sehingga kontribusinya negatif sebesar nilai tersebut. Biaya ini bukan seluruhnya biaya yang dapat dihindari karena sebagian telah dikeluarkan sebelum inspeksi mill.
- Porsi 23/230 atau 10,00% adalah **porsi lot**, bukan utilisasi fasilitas timbang atau transportasi. Utilisasi memerlukan durasi pemakaian dan kapasitas tersedia.
- Kontribusi rata-rata Varian 3 yang lebih tinggi belum membuktikan bahwa mengubah urutan activity akan meningkatkan laba lot lain.

### 05 As Is No Action and To Be
- **As-Is**: Varian 1 dan 3 bersama-sama menghasilkan kontribusi MYR 707.865,40; Varian 2 mencatat kontribusi −MYR 550.025,75.
- **No-Action**: Jika volume, komposisi, dan biaya tetap sama, kerugian pada varian penolakan berpotensi berulang. Ini skenario bersyarat, bukan proyeksi terukur.
- **To-Be**: Uji perbaikan grading dan pencegahan reject dengan model Q08. Model tersebut mengasumsikan penurunan 15% dari seluruh 29 reject (4,35 lot ekuivalen) dan net benefit **MYR 113.151,43**, setelah biaya pengolahan tambahan, CAPEX, dan OPEX. Angka ini merupakan hasil skenario Q08, bukan manfaat terukur dari perubahan varian; tidak ditambahkan lagi sebagai manfaat Q01.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Gunakan hasil DuckDB untuk Q01 dan cocokkan selisih urutan pada ilustrasi Celonis bila masih dipakai, bandingkan Varian 1 dan 3 dalam periode setara, lalu verifikasi alasan reject sebelum menetapkan intervensi grading.
- **Risiko**: Menetapkan Varian 3 sebagai standar berdasarkan rata-rata agregat dapat mengabaikan pengaruh lonjakan volume dan perbedaan karakteristik lot.
- **Asumsi dan batasan**: Throughput adalah selisih timestamp event terakhir dan pertama per case. Event log menunjukkan urutan tercatat dan hubungan waktu; penyebab operasional memerlukan bukti tambahan.

### 07 Evidence File Paths and SQL References
- [Query Q01](../../02_SQL/queries_by_question/Q01.sql)
- [Profil varian SQL](../../02_SQL/results/Q01_01.csv)
- [Perbandingan periode](../../02_SQL/results/Q01_02.csv)
- [Urutan aktivitas lengkap tiga varian DuckDB](../../02_SQL/results/Q01_04.csv)
- [Kumpulan activity Varian 1 dan 3](../../02_SQL/results/Q01_03.csv)
- [Daftar tiga varian Celonis](../../03_CELONIS_EVIDENCE/Q01/Q01_variant_list_top3.png)
- [Model Q08](../Q08/jawaban.md)
