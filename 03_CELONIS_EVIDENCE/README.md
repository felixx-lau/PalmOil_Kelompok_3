# Asal bukti visual Palm Oil

Rilis 11 November 2026. Angka utama berasal dari DuckDB, bukan hasil pembacaan gambar. `evidence_manifest.json` mencatat asal dan hash setiap PNG.

File `*_sql.png` dibuat sendiri oleh `generate_evidence.py` dari hasil query/CSV rilis terbaru. Setiap gambar menyebut bahwa ia bukan ekspor Celonis. Actual Process Map SQL disajikan sebagai matriks adjacency: setiap sel bernilai adalah panah directly-follows pada urutan completion timestamp, event_id. Ini mempertahankan semua hubungan tanpa menganggapnya sebagai dependensi fisik. Daftar edge lengkap ada di Q01/Q01_actual_process_edges_sql.csv.

PNG lama berupa tangkapan layar antarmuka yang disediakan bersama proyek. Nama file lama tidak sama dengan target savefig script generator versi sebelumnya. Pemeriksaan visual menunjukkan tampilan tabel/peta aplikasi; revisi ini tidak membuktikan asal aplikasi, workspace, filter, atau konfigurasi sorting secara independen. Tidak ada screenshot Celonis baru yang dibuat atau diklaim terverifikasi dalam revisi ini. Jangan melabeli semua PNG lama sebagai keluaran matplotlib atau semua PNG sebagai ekspor Celonis terverifikasi.

Daftar varian pada tangkapan layar lama adalah 62/23/17; SQL rilis adalah 61/23/17. Angka finansial/waktu selalu mengikuti grouping SQL. Penyebab selisih satu case belum direkonsiliasi. Peta lama Q01_process_map_overview_part1/part2 ditautkan di jawaban sebagai ilustrasi antarmuka lama, dengan batas asal bukti ini.

Jika rubric mewajibkan bukti Celonis terverifikasi, impor CSV rilis baru pada workspace yang digunakan kelompok dan ambil screenshot beserta nama analisis/filter/sorting. Grafik SQL tidak menggantikan persyaratan khusus penggunaan aplikasi tersebut.
