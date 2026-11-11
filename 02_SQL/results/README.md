# Hasil DuckDB Q01 sampai Q10

Dibangun ulang dari CSV rilis 11 November 2026 melalui `python3 02_SQL/run_pipeline.py`. Nomor suffix mengikuti urutan SELECT tiap query. Q05_03 memuat waiting per tahap; Q05_04 beban harian semua fasilitas. Q07–Q10 memerlukan 06_scenario_model.sql pada koneksi yang sama. Financial reconciliation Q10_04 harus nol. Tabel uang memakai MYR; konversi IDR memakai 4.384,87.
