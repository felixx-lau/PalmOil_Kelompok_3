# Audit kesesuaian submission Palm Oil

> Pembaruan setelah audit: Q02 pada jawaban Markdown/Word, SQL, dan enam CSV hasil sudah direvisi. Temuan Q02 di bawah merekam kondisi saat audit awal; slide, executive summary, full report, dan perbaikan bagian lain belum diselaraskan oleh revisi Q02 ini.

Tanggal audit: 8 November 2026. Kesimpulan: **struktur submission sudah mengikuti panduan, tetapi paket belum siap dinyatakan seluruhnya sesuai. Q02 belum diperbaiki.** Q01 dan Q03 sudah direvisi pada berkas jawaban terpisah; revisi tersebut belum tercermin pada seluruh dokumen gabungan dan PDF final.

## 1 Acuan dan ruang lingkup

Acuan utama: [Panduan tugas PDF](</Users/felix/Downloads/24SI1 - Group03 - Palm Oil.pdf>), khususnya halaman 2–7 dan 17–21. Dokumentasi dataset yang diperiksa: `business_process_description.md`, `data_dictionary.md`, `dataset_background.md`, dan `laboratory_instructions.md` pada folder `/Users/felix/Downloads/OneDrive_1_11-2-2026/documentation/`.

Audit meliputi inventaris seluruh file proyek, pembacaan jawaban Markdown Q01–Q10, ekstraksi teks semua DOCX, pemeriksaan teks dan render PDF slide serta executive summary, pengujian SQL import/profiling/cleaning/validation dan Q01–Q10 di DuckDB, rekonsiliasi CSV bersih, pengecekan referensi file, dan penghitungan ulang konversi dalam dua CSV finansial. Pipeline diuji di memori; CSV submission tidak ditimpa. Script finansial 04 juga berhasil dieksekusi. Ekspor 05 diuji dengan target dialihkan ke file sementara di `/tmp`, kemudian dibaca kembali; CSV submission tidak ditimpa. Pembuat PDF/grafik diperiksa sebagai kode tanpa membuat ulang output submission.

Batas audit: tidak mengakses ulang workspace Celonis atau membuktikan ulang seluruh sumber agronomi/harga alat. Ekstraksi semua DOCX memeriksa konten, bukan sertifikasi visual setiap halaman DOCX. Tampilan PDF ditinjau sebagai dokumen yang tersedia; durasi penyampaian presentasi 15 menit memerlukan latihan tim.

Dokumentasi dataset menyebut organisasi fiktif, waktu UTC, slot employee/resource virtual dengan ketersediaan kontinu, dan biaya simulasi. Klaim tentang gaji tetap, shift nyata, musim panen nyata, kondisi buah, atau mekanisme boiler tidak boleh disajikan sebagai temuan dataset tanpa bukti tambahan.

## 2 Kesesuaian dengan deliverable PDF

| Ketentuan | Status | Hasil pemeriksaan |
|---|---|---|
| Folder utama dan Q01–Q10 | Ada | Struktur dasar sesuai halaman 17–18; jawaban dan bukti per Q tersedia. |
| Template tujuh bagian jawaban | Ada | Semua jawaban memiliki tujuh bagian; kesamaan format belum menjamin angka dan klaim benar. |
| Q01 discovery dan tiga varian | Mayoritas sesuai | Revisi sudah membedakan Celonis 62/23/17 dari SQL 61/23/17 serta menghapus klaim kausal paralelisasi. Tambahkan rujukan langsung dan penjelasan Actual Process Map agar pemetaan alur yang diminta halaman 5 eksplisit di jawaban. Screenshot peta sudah ada di folder Q01. |
| Q02 outcomes dan cost leakage | Belum sesuai penuh | Outcome benar, tetapi denominator, batas atas skenario, rincian biaya dan referensi bukti masih perlu diperbaiki. |
| Q03 waiting processing SLA | Mayoritas sesuai | Jawaban terpisah sudah menyatakan lonjakan Mei, 67 pengiriman pada 8–9 Mei, dan beban harian FAC-029. Perhitungan memakai CSV sebelum patch cleaning. |
| Q04–Q06 diagnostik | Perlu revisi | Masih ada klaim sebab yang tidak dibuktikan, interpretasi utilisasi keliru, dan rincian biaya rework salah. |
| Q07–Q10 what-if dan sensitivitas | Perlu revisi | Perbandingan skenario ada, tetapi Q07/Q09 berbeda dengan SQL; Q10 belum sensitif terhadap allowance dan aritmetika SQL tidak merekonsiliasi. |
| Slides semua Q01–Q10 | Ada tetapi usang | 16 halaman, seluruh Q tercakup; isi dan grafik lama masih bertentangan dengan revisi. |
| Executive Summary 1–2 halaman | Format memenuhi | Dua halaman, tetapi angka/klaim lama, istilah data riil, dan payback belum dapat dipertahankan. |
| Kurs dan MYR ke IDR | Sebagian sesuai | Raw rates dan midpoint sesuai angka panduan; banyak hasil perkalian IDR salah. |
| Kontribusi individu | Belum lengkap | Nama anggota 2–4 masih placeholder dan student ID belum terverifikasi. |
| Transparansi evidence | Sebagian | Delapan nama file bukti yang dirujuk jawaban tidak ada; banyak tautan menunjuk folder Desktop lama. |

## 3 Status Q02 secara khusus

[Jawaban Q02](../04_JAWABAN/Q02/jawaban.md) dan versi Word masih memuat masalah berikut.

1. **Denominator tercampur.** Bagian As-Is menulis “12,61% (29 dari 218 lot panen)”. Yang benar: 29/230 = **12,61% dari seluruh case**, sedangkan 29/218 = **13,30% dari lot yang dipanen/tiba di mill**, dengan 12 cancelled dikecualikan.
2. **RM 953.023,09 belum diberi batasan yang benar.** Nilai itu menjumlahkan biaya reject RM 711.861,41 dan kontribusi hipotetis RM 241.161,68. Harus ditulis sebagai batas atas skenario dengan asumsi seluruh 29 lot memenuhi mutu dan dapat diselamatkan, bukan estimasi realistis/manfaat pasti. Biaya dan hasil intervensi perlu dimodelkan terpisah.
3. **Angka downstream reject salah ketik.** Tabel menulis RM 4.865,67; query menghasilkan **RM 4.864,67**. Baris total downstream pada tabel ikut berbeda RM 1.
4. **Breakdown belum lengkap.** Crop + transport + downstream tidak mencakup seluruh biaya kebun/perencanaan/harvest operations. Tampilkan komponen tersisa agar jumlah kolom bisa direkonsiliasi. Residual RM 13.947,71 pada lot reject bukan seluruhnya inspeksi/triage mill.
5. **Label downstream menyesatkan.** Definisi SQL mengelompokkan kegiatan selain kebun/transport, termasuk penutupan lot dan administrasi, sehingga tidak semuanya biaya milling. Cancelled pun memiliki downstream RM 316,84 dengan definisi ini.
6. **Klaim disposal tidak terbukti.** Log menunjukkan reject dan nol revenue, bukan bukti buah dimusnahkan/dikembalikan tanpa kemungkinan pemanfaatan lain.
7. **No-Action dan To-Be perlu horizon konsisten.** Rata-rata tahunan dari total 24 bulan harus dinyatakan sebagai annualisasi bersyarat, bukan pola kronis terbukti. Rentang manfaat 15–30% perlu perhitungan yang dapat direplikasi; jangan sekadar menggandakan hasil program dengan biaya tetap.
8. **Referensi bukti hilang.** `Q02_outcomes_cost_breakdown.png` tidak ada. Screenshot yang tersedia adalah `Q02_lot_outcomes.png`.

Hasil query outcome yang dikonfirmasi:

| Outcome | Lot | Biaya MYR | Revenue MYR | Contribution MYR |
|---|---|---|---|---|
| Processed dispatched | 189 | 5.502.753,42 | 7.074.461,68 | +1.571.708,26 |
| Rejected | 29 | 711.861,41 | 0,00 | −711.861,41 |
| Cancelled | 12 | 1.430,83 | 0,00 | −1.430,83 |
| Total | 230 | 6.216.045,66 | 7.074.461,68 | +858.416,02 |

## 4 Temuan data dan SQL

### Cleaning dan validasi

Import, profiling, cleaning, dan validation dapat dieksekusi bersama dalam satu koneksi. Hasil cleaning identik dengan CSV yang ada, tetapi masih menyisakan:

- **20 event** dengan `case_type` berbeda dari `case_master`.
- **6 event** dengan key employee/resource kosong: empat employee kosong dan dua resource kosong. Event: `EVT-0005598`, `EVT-0004606`, `EVT-0004304`, `EVT-0001776`, `EVT-0002311`, `EVT-0001230`.
- **EVT-0004091**: ready time sama dengan start `2026-05-08 23:41:00`, tetapi waiting tercatat 278 menit. Selisih start minus ready menjadi nol. Koreksi harus memakai bukti sumber, bukan menebak timestamp.
- `02b_patch_clean.sql` **belum ada** di folder saat audit.
- Laporan kualitas masih mengklaim 100% master match/0 missing dan ready time sama dengan end pada seluruh 17 inversi. Pemeriksaan raw mengonfirmasi hanya 16 dari 17 inversi memiliki ready time sama dengan end semula. Klaim tersebut perlu dibatasi dan diperbaiki sesuai pengecualian.
- Validasi employee/resource mengecualikan NULL dari unmatched check, sehingga hasil “unmapped = 0” tidak membuktikan tidak ada key kosong. Tambahkan pemeriksaan kelengkapan, `case_type`, kesamaan timestamp dengan end, persamaan waiting dan duration, serta dependency dan pengakuan revenue tepat satu kali per dispatched case.

Yang lolos: 6.179 event unik, 230 case, tidak ada duration nonpositif/inversi tersisa, tidak ada waiting negatif pada kolom tercatat, identitas biaya dan contribution konsisten, serta positive revenue pada dispatch dan negative revenue pada allowance.

### Q04 sampai Q06

- **Q04:** SQL sudah menyediakan bucket waktu dan biaya reject RM 711.861,41 dengan definisi akhir `FFB Harvested` sampai awal `Mill Weighbridge Inbound`. Jadi permintaan query ini sebagian besar sudah tersedia. Bucket menggunakan durasi yang dibulatkan dan batas `BETWEEN` yang beririsan; lebih jelas memakai interval tidak tumpang tindih pada durasi asli. Narasi masih menyimpulkan pembatasan <3 jam mencegah sebagian besar reject, padahal rejection rate **18,18% / 7,53% / 22,58% / 14,75%** tidak monoton. Klaim kematangan sebagai penyebab yang “terbukti” juga belum didukung indikator langsung.
- **Q05:** SQL sudah memisahkan waiting dan processing per activity/fasilitas, tetapi belum memiliki agregasi beban harian dan total waiting per tahap dalam file Q05. Query beban harian tersedia di Q03 revisi. Narasi Q05 masih menyebut prioritas operator, pre-heating boiler, dan porsi 79,4% sebagai utilisasi. Waiting harus dijelaskan sebagai episode Mei. Mengubah 38,47 jam jumlah waiting menjadi 28 lot kapasitas baru juga belum membuktikan output tambahan.
- **Q06:** Filter SQL **sudah benar**, yaitu `rework_flag = true OR activity ILIKE '%rework%'`, menghasilkan 76 execution dan **RM 21.823,19**. Akan tetapi, komponen pada tabel jawaban tidak sama dengan query. Total komponen aktual: labor **RM 2.337,03**, material **RM 13.007,56**, equipment **RM 4.456,22**, overhead **RM 2.022,38**. Total biaya benar tidak membenarkan rincian komponen yang salah. Narasi pemanasan ulang/zat kimia tertentu, kerugian tahunan >RM 21.000, dan manfaat minimal +RM 19.000 masih perlu diperbaiki. Recorded rework tidak otomatis seluruhnya avoidable; mandatory retesting dipertahankan.

### Q07 sampai Q10

| Bagian | Isi laporan saat ini | Hasil query atau rekonsiliasi | Implikasi |
|---|---|---|---|
| Q07 savings | RM 3.290,00 | **RM 917,19** | Rumus SQL: total equipment cost RM 38.216,18 × 12% × 20%. |
| Q07 net benefit | −RM 3.910,00 | **−RM 6.282,81** | Berlaku dengan CAPEX 6.000 dan satu input OPEX 1.200 sebagaimana query; belum mengoreksi isu annual OPEX/horizon. |
| Q07 rata-rata waiting | 11,87 menit per rit | 11,87 per event pada 654 event; **35,61 menit per lot** pada 218 lot | Bedakan denominator event dan perjalanan/lot. Penurunan 20% adalah what-if, bukan hasil implementasi terbukti. |
| Q08 net benefit | RM 113.151,43 | Sekitar **RM 113.151,44** | Selisih pembulatan kecil; gunakan nilai presisi yang sama. Pengurangan 15% relatif berbeda dari 15 percentage points. |
| Q09 growth | Net benefit RM 78.450,00 | **RM 110.756,05** | SQL memakai 28,35 lot ekuivalen, tetapi kolom volume dibulatkan menjadi 217 total lot. Laporan perlu memilih volume dan asumsi yang konsisten. |
| Q09 revenue growth | RM 530.538,32 | Kolom SQL bernama revenue berisi **RM 235.756,05** | Rumus SQL sebenarnya incremental contribution sebelum investasi, bukan revenue; kedua definisi tidak sama. |
| Q10 sensitivitas P2 | Selalu diprioritaskan +RM 9.703,82 | Jika allowance tidak turun: **−RM 770,72** | Dengan savings rework RM 8.729,28 dan biaya 9.500, allowance perlu turun >sekitar **3,68%** agar net benefit positif, dengan parameter lain tetap. |
| Q10 SQL To-Be | Revenue 7.247.761,11; cost 6.270.219,12; contribution 981.271,27 | Revenue − cost = **977.541,99**, bukan 981.271,27 | Perbedaan **RM 3.729,28**. Cost SQL perlu direkonsiliasi dengan net savings dan biaya portofolio. |

`scenario_comparison.csv` untuk Q09 growth juga tidak merekonsiliasi: revenue 7.605.000 − cost 6.668.000 = **RM 937.000**, sedangkan contribution tercantum **RM 936.866,02**.

Q09 belum membuktikan queue turun menjadi 2,8/8,5 menit dari model antrean. Peningkatan kapasitas 15% tidak otomatis mempersingkat semua durasi atau menjamin output bertambah. Pisahkan asumsi laju layanan, supply, demand, energy/labor tambahan dan antrean.

Q07–Q10 masih memerlukan keseragaman horizon: asumsi menyebut OPEX tahunan, sedangkan volume dasar 24 bulan, namun biaya tahunan hanya dikurangkan sekali. Tambahkan sensitivitas terhadap effectiveness, avoidable share, CAPEX/OPEX dan overlap manfaat. Payback <6 bulan belum memiliki jadwal arus kas untuk mendukungnya.

### Reprodusibilitas pipeline

- README menjalankan `duckdb < file.sql` terpisah tanpa nama database. Tabel dari proses sebelumnya tidak otomatis tersedia di proses berikutnya. Gunakan database persisten yang sama atau satu sesi Python/DuckDB.
- `04_financial_analysis.sql` membaca ulang CSV lama ke `clean_events`. Jika patch baru dijalankan sebelum 04 tetapi belum diekspor, perubahan dapat tertimpa. Pisahkan analisis hasil cleaning dari impor ulang CSV atau atur urutan secara eksplisit.
- `generate_evidence.py` dan `build_pdfs.py` memakai prefix `24SI1_Group03_Palm_Oil/`, sehingga tidak langsung sesuai saat dijalankan dari root proyek seperti petunjuk README. Isi grafik/PDF juga banyak ditulis langsung dalam kode, bukan membaca seluruh jawaban revisi. Menjalankan ulang script saja belum menjamin semua perbaikan ikut masuk.

## 5 Konversi IDR dan dokumen akhir

Kurs jual 4.408,94, kurs beli 4.360,80, dan midpoint **4.384,87 IDR/MYR** cocok dengan panduan. Audit ini memeriksa konsistensi terhadap panduan, bukan mengambil ulang data historis BI.

Namun penghitungan ulang menemukan **42 pasangan nominal MYR/IDR** pada `financial_baseline.csv` dan `scenario_comparison.csv` berbeda lebih dari Rp0,02 dari perkalian yang semestinya. Ini salah hitung konversi, bukan alasan mengganti kurs atau baseline MYR.

| Baseline | MYR benar | IDR tercantum | IDR hasil MYR × 4.384,87 |
|---|---|---|---|
| Net revenue | 7.074.461,68 | 31.020.593.293,47 | **31.020.594.786,78** |
| Operational cost | 6.216.045,66 | 27.256.552.698,81 | **27.256.552.133,16** |
| Profit contribution | 858.416,02 | 3.764.040.594,66 | **3.764.042.653,62** |

Baseline MYR, jumlah outcome 189/29/12 dan kurs tetap dipertahankan. Besaran koreksi IDR relatif kecil terhadap total, tetapi tetap perlu dibetulkan agar tabel dan query konsisten.

Dokumen berikut belum sinkron dengan revisi Q01/Q03 dan temuan audit:

- `00_START_HERE/PALM_OIL_PROCESS_MINING_FULL_REPORT.docx` masih memuat klaim paralelisasi, koordinasi regu, kesalahan denominator Q02, dan payback lama.
- `06_PRESENTATION/slides.md`, `.docx`, `.pdf` masih memuat Q01/Q03 versi lama serta skenario Q07/Q09/Q10 lama. PDF berisi 16 halaman dan mencakup semua Q; kelengkapan jumlah slide tidak meniadakan kesalahan isi.
- `07_EXECUTIVE_SUMMARY/executive_summary.md`, `.docx`, `.pdf` masih memuat klaim 100% master, economic damage tanpa batas atas, dan payback <6 bulan. PDF menyebut “dataset transaksi riil” meskipun dataset synthetic. Kalimat “Disetujui oleh Executive Board” juga tidak memiliki bukti persetujuan dan sebaiknya diganti identitas penyusun.
- `00_START_HERE/README.md` dan `.docx` masih memberi status TERPENUHI secara menyeluruh meskipun ada kesalahan data/evidence serta hasil revisi belum disebarkan.
- `05_FINANCIAL/scenario_assumptions.*` perlu mengikuti hasil query, horizon, dan sensitivitas terbaru. RM 8.729,28 adalah 40% dari seluruh recorded rework RM 21.823,19, bukan hanya biaya retest lab RM 2.308,02.

## 6 Evidence dan kontribusi individu

Delapan referensi gambar yang tidak ditemukan:

| Jawaban | Nama yang dirujuk tetapi tidak ada |
|---|---|
| Q02 | Q02_outcomes_cost_breakdown.png |
| Q04 | Q04_time_to_mill_vs_rejection.png |
| Q05 | Q05_milling_facility_bottlenecks.png |
| Q06 | Q06_rework_and_sales_allowances.png |
| Q07 | Q07_transport_scheduling_scenario.png |
| Q08 | Q08_ffb_rejection_reduction_model.png |
| Q09 | Q09_milling_capacity_investment_model.png |
| Q10 | Q10_business_case_ranking_myr_idr.png |

Screenshot lain memang ada pada folder masing-masing Q; masalahnya nama/isi bukti yang dirujuk tidak selalu sama dengan file yang tersedia. Ganti rujukan ke bukti yang benar atau buat grafik analisis tambahan dengan jelas membedakannya dari export Celonis. Perbaiki tautan absolut `file:///Users/felix/Desktop/...` menjadi relatif agar paket portabel.

`08_CONTRIBUTIONS/member_contributions.csv` masih memakai Group Member 2/3/4 dan ID 2406000001–2406000004. Nama/NIM dan peran aktual harus dikonfirmasi tim; audit tidak mengarang identitas anggota. Rekaman kontribusi belum cukup untuk mengonfirmasi peran nyata masing-masing anggota.

`09_REFERENCES/sources.*` memuat daftar rujukan, tetapi beberapa entri tidak dilengkapi URL/DOI/halaman yang mendukung klaim teknis. Keberadaan judul dalam daftar pustaka belum membuktikan klaim tekanan, FFA, spesifikasi alat, atau biaya implementasi.

## 7 Urutan penyelesaian

1. Selesaikan patch cleaning dengan bukti sumber, perkuat validasi, lalu ekspor ulang CSV tanpa mengubah 6.179 event/230 case yang valid.
2. Perbaiki Q02 serta laporan data quality. Q01 perlu rujukan eksplisit ke peta proses; hitung ulang Q01/Q03 setelah ekspor.
3. Selaraskan Q04–Q06 dengan data; pertahankan SQL rework Q06 yang sudah benar dan perbaiki tabel komponennya.
4. Hitung ulang Q07–Q10 dari model yang sama, samakan horizon, perbaiki sensitivitas dan rekonsiliasi revenue − cost = contribution.
5. Hitung ulang semua nilai IDR, perbaiki delapan referensi evidence, serta isi kontribusi dengan identitas sebenarnya.
6. Sinkronkan MD, DOCX, full report, grafik, slide dan executive summary; buat ulang PDF setelah substansi selesai. Lakukan final review dan latihan presentasi 15 menit.

Hasil cek mesin tersimpan di [audit_review_results.json](../01_DATA/validation/audit_review_results.json), termasuk rincian konversi IDR dan output query. Inventaris berkas tersedia di [audit_file_inventory.json](../01_DATA/validation/audit_file_inventory.json). Audit ini menambah laporan pemeriksaan; tidak mengubah jawaban Q02, CSV sumber, ataupun dokumen submission lainnya.
