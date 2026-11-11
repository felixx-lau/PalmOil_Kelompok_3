# Hasil Q02

Jalankan `python3 02_SQL/export_q02_results.py` dari root proyek untuk mengeksekusi `Q02.sql` terhadap CSV cleaned saat ini. Membutuhkan package Python `duckdb`.

| File | Isi |
|---|---|
| Q02_01.csv | Outcome dan finansial dalam MYR serta IDR |
| Q02_02.csv | Tujuh komponen biaya yang saling terpisah dan lengkap |
| Q02_03.csv | Denominator seluruh case dan harvested case |
| Q02_04.csv | Counterfactual batas atas dengan seluruh 29 reject terselamatkan dan benchmark contribution dibulatkan |
| Q02_05.csv | Validasi outcome eksklusif, rekonsiliasi biaya, contribution, dan baseline |
| Q02_06.csv | Skenario operasional penurunan reject 15% relatif pada volume harvested tetap |

Hasil ini telah dihitung ulang dari CSV rilis final cleaning 11 November 2026. Reproduksi lengkap: `python3 02_SQL/run_pipeline.py`. Angka FX mengikuti input panduan, 4.384,87 IDR/MYR. Tabel finansial dan skenario proyek telah diselaraskan. Tidak ada manfaat program Q08 yang ditambahkan sebagai manfaat independen Q02. Satu event remittance dikarantina; baseline berlaku untuk event yang dipertahankan.
