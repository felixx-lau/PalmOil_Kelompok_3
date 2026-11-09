# Analisis Q02 Descriptive
## FFB Outcomes and Cost Leakage

Dari 230 lot, 189 diproses dan dikirim, 29 ditolak, dan 12 dibatalkan. Lot ditolak mencatat biaya **MYR 711.861,41** tanpa revenue. Angka ini sudah termasuk dalam baseline kontribusi perusahaan; manfaat pemulihan reject harus dinilai sebagai skenario terpisah.

### 01 Evidence and Data Source

**Metode analisis utama: DuckDB SQL.** Query dijalankan pada tabel `clean_events` yang dibaca dari CSV bersih (6.179 event, 230 case). Reproduksi seluruh Q01–Q06: `python3 02_SQL/export_q01_q06_results.py` dari folder induk proyek, menggunakan package Python `duckdb`. Hasil SELECT disimpan ke `02_SQL/results/`; angka tabel dan kesimpulan memakai hasil DuckDB. Gambar Celonis merupakan ilustrasi tambahan.

- **Data**: `01_DATA/cleaned/celonis_event_log_clean.csv`, 6.179 event dan 230 case, dengan jendela kedatangan Oktober 2024–September 2026. Dataset merupakan simulasi; timestamp memakai UTC.
- **Query**: `02_SQL/queries_by_question/Q02.sql`; ekspor ulang hasil dengan `python3 02_SQL/export_q02_results.py` dari root proyek.
- **Ilustrasi Celonis tambahan**: `03_CELONIS_EVIDENCE/Q02/Q02_lot_outcomes.png`.
- **Output**: `02_SQL/results/Q02_01.csv` sampai `Q02_06.csv`.

| Outcome | Lot | Porsi seluruh case | Revenue MYR | Biaya MYR | Contribution MYR |
|---|---|---|---|---|---|
| Processed / Dispatched | 189 | 82,17% | 7.074.461,68 | 5.502.753,42 | +1.571.708,26 |
| Rejected | 29 | 12,61% | 0,00 | 711.861,41 | −711.861,41 |
| Cancelled | 12 | 5,22% | 0,00 | 1.430,83 | −1.430,83 |
| **Total** | **230** | **100,00%** | **7.074.461,68** | **6.216.045,66** | **+858.416,02** |

Rincian biaya berikut saling terpisah dan mencakup seluruh biaya. Crop adalah material pada `FFB Harvested`; komponen nonmaterial panen dipisahkan dari kegiatan kebun lainnya. Penutupan lot termasuk administrasi, sehingga biaya cancelled atau rejected tidak keliru disebut biaya milling.

| Komponen biaya MYR | Processed | Rejected | Cancelled | Total |
|---|---|---|---|---|
| Crop production material saat panen | 4.232.310,00 | 675.040,72 | 0,00 | 4.907.350,72 |
| Labor equipment overhead saat panen | 18.731,17 | 2.918,10 | 0,00 | 21.649,27 |
| Perencanaan grading dan kegiatan kebun lainnya | 37.390,78 | 6.164,94 | 1.113,99 | 44.669,71 |
| Transport dan logistik | 142.301,63 | 22.872,98 | 0,00 | 165.174,61 |
| Weighbridge penerimaan dan inspeksi | 39.947,39 | 4.077,73 | 0,00 | 44.025,12 |
| Milling processing dan pembaruan storage | 952.643,46 | 0,00 | 0,00 | 952.643,46 |
| Dispatch finance dan penutupan lot | 79.428,99 | 786,94 | 316,84 | 80.532,77 |
| **Total biaya** | **5.502.753,42** | **711.861,41** | **1.430,83** | **6.216.045,66** |

Konversi menggunakan angka acuan panduan: **1 MYR = 4.384,87 IDR**, midpoint kurs BI 13 Oktober 2026. Perkalian dilakukan sebelum pembulatan ke dua desimal.

| Contribution | Nilai IDR |
|---|---|
| Processed / Dispatched | +6.891.736.398,03 |
| Rejected | −3.121.419.740,87 |
| Cancelled | −6.274.003,54 |
| **Total baseline** | **+3.764.042.653,62** |

### 02 Descriptive Finding
1. **Dua denominator penolakan**: 29/230 = **12,61% dari seluruh case**, termasuk cancelled. Jika cancelled dikecualikan, 29/218 = **13,30% dari lot yang dipanen**. Keduanya sah untuk pertanyaan yang berbeda dan tidak boleh dipertukarkan.
2. **Biaya reject**: MYR 675.040,72 atau 94,83% biaya reject merupakan crop production material yang dialokasikan saat panen. Biaya transportnya MYR 22.872,98. Sisa MYR 13.947,71 mencakup operasi panen, kegiatan kebun lainnya, penerimaan, dan penutupan lot; seluruhnya tidak boleh dilabeli biaya inspeksi.
3. **Cancelled**: Tidak terdapat event `FFB Harvested` pada 12 cancelled lot. Biaya tercatat MYR 1.430,83 berasal dari kegiatan kebun/perencanaan/pembatalan dan penutupan lot, rata-rata MYR 119,24 per lot.

### 03 Diagnostic Reasoning
Penolakan terjadi setelah biaya crop dan transport tercatat, sehingga lot tersebut menghasilkan kontribusi negatif. Crop cost yang telah dialokasikan pada lot panen merupakan sunk cost untuk keputusan pengolahan berikutnya; nilainya tidak otomatis menjadi penghematan kas bila grading diperketat.

Log membuktikan outcome reject dan tidak adanya revenue pada lot tersebut. Log belum membuktikan bahwa buah mentah atau busuk adalah penyebab setiap reject, maupun bahwa buah dimusnahkan atau dikembalikan. Alasan inspeksi dan tindak lanjut fisik perlu diverifikasi sebelum menyimpulkan akar masalah atau nilai pemulihan.

### 04 Business and Financial Implication
**Dampak tercatat** adalah kontribusi −MYR 711.861,41 pada rejected dan −MYR 1.430,83 pada cancelled. Keduanya sudah diperhitungkan dalam baseline +MYR 858.416,02, sehingga tidak dikurangkan lagi dari baseline.

Selisih contribution **MYR 953.023,09** merupakan **batas atas dalam skenario seluruh 29 reject dapat diselamatkan**. Dengan benchmark kontribusi processed yang dibulatkan menjadi MYR 8.315,92 per lot:

- Kontribusi positif hipotetis: 29 × MYR 8.315,92 = **MYR 241.161,68**.
- Selisih terhadap kontribusi reject aktual: MYR 241.161,68 − (−MYR 711.861,41) = **MYR 953.023,09**, setara **IDR 4.178.882.356,65**.

Ini perbandingan counterfactual, **bukan kerugian tambahan tercatat, perkiraan realistis, atau manfaat bersih program**. Asumsinya semua reject memenuhi mutu, dapat diolah dan dijual, serta mencapai benchmark processed; biaya intervensi dan kelayakannya belum dibuktikan. Cost leakage dan selisih skenario ini tidak boleh dijumlahkan lagi sebagai dua manfaat pemulihan.

### 05 As Is No Action and To Be
- **As-Is**: 29 reject dari 218 harvested lot (13,30%); biaya reject MYR 711.861,41 pada horizon dataset 24 bulan.
- **No-Action**: Pada volume, komposisi outcome, dan biaya yang sama, kontribusi kategori reject dapat kembali sebesar −MYR 711.861,41. Ini skenario pengulangan bersyarat, bukan bukti kerugian rutin tahunan atau tren masa depan.
- **To-Be**: Uji penurunan reject **15% relatif**, dari 29 menjadi 24,65 lot ekuivalen pada volume tetap 218 harvested lot. Ini setara 4,35 lot terselamatkan dan rejection rate sekitar **11,31%**, bukan penurunan 15 percentage points. Pecahan lot merupakan nilai harapan skenario, bukan jumlah lot aktual.

Manfaat finansial To-Be harus dihitung dari incremental revenue dan biaya yang benar-benar avoidable, dikurangi biaya pengolahan tambahan, implementasi, dan OPEX pada horizon yang sama. Manfaat bersih belum dapat dipastikan tanpa biaya program dan kelayakan pemulihan; evaluasi finansial rinci dilakukan pada Q08. Sekadar memindahkan titik reject ke kebun belum otomatis menghasilkan lot tambahan yang layak dijual.

### 06 Recommendation Risk and Assumptions
- **Rekomendasi**: Verifikasi alasan reject dan lakukan pilot inspeksi awal. Bedakan pencegahan penurunan kualitas yang memungkinkan pengolahan dari penolakan lebih dini yang hanya menghindari biaya lanjutan. Pertahankan standar mutu.
- **Risiko**: Salah grading dapat menolak buah layak atau meloloskan buah tidak layak; biaya inspeksi dan tambahan pengolahan dapat mengurangi manfaat.
- **Asumsi dan batasan**: Outcome ditentukan dari event cancelled, rejected, dan dispatch; setiap case harus tepat satu outcome. Biaya adalah alokasi dalam simulasi, bukan seluruhnya arus kas yang bisa dihindari. Perhitungan memakai CSV saat ini dan perlu diulang setelah patch cleaning.

### 07 Evidence File Paths and SQL References
- [Query Q02](../../02_SQL/queries_by_question/Q02.sql)
- [Outcome dan finansial MYR IDR](../../02_SQL/results/Q02_01.csv)
- [Rincian biaya lengkap](../../02_SQL/results/Q02_02.csv)
- [Definisi dua denominator](../../02_SQL/results/Q02_03.csv)
- [Batas atas skenario seluruh reject terselamatkan](../../02_SQL/results/Q02_04.csv)
- [Validasi outcome biaya dan kontribusi](../../02_SQL/results/Q02_05.csv)
- [Skenario penurunan reject 15 persen relatif](../../02_SQL/results/Q02_06.csv)
- [Bukti outcome Celonis](../../03_CELONIS_EVIDENCE/Q02/Q02_lot_outcomes.png)
- [Model program Q08](../Q08/jawaban.md)
