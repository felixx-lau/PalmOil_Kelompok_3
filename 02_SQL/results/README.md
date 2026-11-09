# Hasil analisis DuckDB Q01 sampai Q06

Reproduksi dari folder induk proyek:

```bash
python3 02_SQL/export_q01_q06_results.py
```

Dijalankan pada 9 November 2026 memakai DuckDB 2.0.0 terhadap CSV bersih yang tersedia: 6.179 event dan 230 case. Data sumber tidak diubah. Setiap SELECT pada query Q01–Q06 diekspor berurutan ke CSV. Pipeline cleaning tidak dijalankan ulang; setelah perubahan CSV sumber, hitung ulang seluruh hasil dan jawaban.

| File | Isi |
|---|---|
| Q01_01.csv | Sepuluh varian terbesar dan metrik waktu serta finansial |
| Q01_02.csv | Paparan periode lonjakan Varian 1 dan 3 |
| Q01_03.csv | Kumpulan dan jumlah aktivitas Varian 1 dan 3 |
| Q01_04.csv | Urutan lengkap tiga varian terbesar dari case perwakilan |
| Q02_01.csv sampai Q02_06.csv | Outcome, biaya, kontribusi, dan rekonsiliasi Q02 |
| Q03_01.csv sampai Q03_04.csv | Kinerja tahap, waiting bulanan, pengiriman harian, dan beban sterilizer |
| Q04_01.csv | Lead time panen ke penerimaan mill dan rejection |
| Q04_02.csv | Grade provisional dan rejection |
| Q05_01.csv | Processing, waiting, dan biaya per aktivitas stasiun |
| Q05_02.csv | Beban dan biaya per fasilitas |
| Q06_01.csv | Komponen biaya rework |
| Q06_02.csv | Detail allowance dan biaya administrasi per lot |
| Q06_03.csv | Ringkasan biaya rework dan pengurangan revenue allowance |

Acuan Q01 adalah varian DuckDB 61/23/17 lot dengan pengurutan timestamp lalu event_id. Screenshot Celonis lama 62/23/17 hanya ilustrasi; rekonsiliasi satu case perlu pemeriksaan urutan terkait. Jangan mencampur denominator. Q06_03 tidak mencakup administrasi allowance pada baris revenue; gunakan Q06_02 untuk total dampak kontribusi.
