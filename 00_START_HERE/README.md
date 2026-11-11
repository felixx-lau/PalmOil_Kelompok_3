# Panduan submission Palm Oil

24SI1 Group 03, revisi 11 November 2026. Proyek menganalisis dataset sintetis FFB harvest hingga CPO dispatch pada cohort 24 bulan Oktober 2024–September 2026. Semua timestamp UTC. Cleaning final sesuai aturan yang didokumentasikan; satu event remittance rusak tetap dikarantina dan satu dependensi trace memiliki pengecualian. Rincian tersedia pada laporan kualitas data, bukan klaim validitas tanpa batas.

## Reproduksi analisis

Dari folder proyek, jalankan:

```bash
python3 02_SQL/run_pipeline.py
python3 -m unittest discover -s tests
```

Butuh Python dan package duckdb. Semua tahap berjalan dalam satu koneksi: import, cleaning, patch, validation, export, impor ulang CSV, model skenario, lalu Q01–Q10. CSV tidak dipublikasikan bila gate gagal. Raw dipertahankan. Hasil analisis ada di `02_SQL/results/`; checksum dan audit rilis ada di `01_DATA/validation/`.

## Navigasi hasil

- [Laporan final cleaning](../01_DATA/validation/data_quality_report.md), [audit patch](../01_DATA/validation/cleaning_patch_audit.csv), [hasil validasi](../01_DATA/validation/validation_results.csv).
- [CSV bersih](../01_DATA/cleaned/celonis_event_log_clean.csv): 6.179 event unik, 230 case.
- [Q01](../04_JAWABAN/Q01/jawaban.md), [Q02](../04_JAWABAN/Q02/jawaban.md), [Q03](../04_JAWABAN/Q03/jawaban.md); jawaban Q04–Q10 berada pada folder paralel.
- [Model skenario bersama](../02_SQL/06_scenario_model.sql), [skenario](../05_FINANCIAL/scenario_comparison.csv), [sensitivitas](../05_FINANCIAL/sensitivity.csv), [asumsi](../05_FINANCIAL/scenario_assumptions.md).
- [Asal bukti visual](../03_CELONIS_EVIDENCE/README.md), [slide](../06_PRESENTATION/slides.pdf), dan [executive summary](../07_EXECUTIVE_SUMMARY/executive_summary.pdf).

## Hasil utama dan batas interpretasi

Q01 menghasilkan tiga varian terbesar 61/23/17 lot dengan sorting timestamp lalu event_id. Tangkapan layar antarmuka lama menampilkan 62/23/17; sumber aplikasi dan pengaturan sortir belum diverifikasi ulang. Semua angka utama memakai SQL, bukan gabungan dua grouping. Actual Process Map dan perbedaan urutan dijelaskan di Q01.

Q02 mencatat 189 processed, 29 rejected, dan 12 cancelled. Rejection rate adalah 12,61% dari seluruh 230 case atau 13,30% dari 218 harvested lot. Biaya reject MYR 711.861,41 sudah masuk baseline; batas atas counterfactual MYR 953.023,09 bukan tambahan kerugian atau manfaat pasti.

Q03 mencatat 1.047,10 jam waiting dan 180 pelanggaran SLA. Seluruh waiting positif tercatat Mei 2026. Data tidak membuktikan antrean kronis, akar masalah tertentu, atau sebab langsung reject. Target Q04 lead time maksimal 3 jam dan rejection rate maksimal 8% merupakan target pilot.

Baseline revenue MYR 7.074.461,68, biaya MYR 6.216.045,66, kontribusi MYR 858.416,02. Konversi dengan input tugas 4.384,87 IDR/MYR menghasilkan kontribusi IDR 3.764.042.653,62. Tidak dilakukan verifikasi web baru terhadap kurs.

Skenario menggunakan OPEX dua tahun, CAPEX sekali. Net benefit Q08 MYR 108.708,02 dan mutu CPO MYR 7.785,54; gabungan MYR 116.493,56 menghasilkan nilai setelah investasi MYR 974.909,58. Ini skenario bersyarat, bukan realisasi atau laba akuntansi setelah depresiasi. Payback belum ditetapkan.

## Bukti dan sinkronisasi

Grafik berlabel SQL dibuat sendiri dari hasil query; bukan ekspor Celonis. Tangkapan layar lama dipertahankan terpisah dan diberi batas asal bukti pada manifest. Tidak ada klaim bahwa workspace Celonis telah diverifikasi ulang atau diimpor ulang dalam revisi ini. Untuk analisis Celonis baru, unggah CSV rilis ini dengan case_id, activity, timestamp, dan event_id sebagai pemecah tie yang konsisten.

Markdown merupakan sumber konten. `build_pdfs.py` membuat dokumen Word, slide PDF dan executive summary dari Markdown terbaru; `generate_evidence.py` membuat grafik SQL. Audit 8 November disimpan sebagai riwayat, bukan status rilis terbaru. Identitas kontribusi anggota tetap perlu disesuaikan oleh kelompok; tidak dibuat nama/ID pengganti.
