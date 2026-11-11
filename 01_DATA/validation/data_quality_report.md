# Laporan final cleaning data Palm Oil

Rilis 11 November 2026, 24SI1 Group 03. Cleaning selesai untuk aturan dataset sintetis yang didokumentasikan. CSV siap dipakai untuk analisis Q01–Q10 dengan batas kelengkapan satu event yang dikarantina. Istilah final berarti pipeline dapat direproduksi dan lolos pemeriksaan yang disebutkan, bukan jaminan bahwa data simulasi mewakili kebenaran lapangan secara sempurna.

## Sumber dan hasil rilis

Data mentah berasal dari sembilan CSV dalam `01_DATA/raw/`. Definisi yang dipakai tersedia pada [data dictionary](source_documentation/data_dictionary.md), [laboratory instructions](source_documentation/laboratory_instructions.md), dan [business process](source_documentation/business_process_description.md). Salinan dokumentasi sumber disertakan agar keputusan cleaning dapat ditinjau tanpa bergantung pada folder di luar proyek.

| Ukuran | Hasil |
|---|---|
| Baris raw | 6.325 |
| Duplikat ekstraksi yang dihapus | 145 |
| Event dengan timestamp tidak dapat dipulihkan | 1 |
| Event akhir | 6.179 |
| Event ID unik | 6.179 |
| Case unik | 230 |
| Pemeriksaan rilis | 26 lolos, 0 gagal |
| Selisih ekspor dan impor ulang CSV | 0 |
| Event berubah dibanding CSV sebelum patch | 27 |

6.325 − 145 − 1 = 6.179. Deduplikasi hanya berdasarkan event ID yang dinormalisasi; pengulangan aktivitas dengan event ID berbeda tetap dipertahankan. Terdapat 76 eksekusi rework menurut flag atau nama aktivitas, termasuk grading ulang dan retest yang sah.

## Perbaikan tahap dasar

Event ID dan master key dinormalisasi dengan trim serta casing. Nama aktivitas, department, role, resource type dan organizational unit dipetakan ke master. Tanggal menggunakan parser day-first; currency prefix dibersihkan sebelum cast DECIMAL. Boolean menerima true/false, yes/no, y/n, 1/0. Tiga material cost kosong dipulihkan melalui persamaan total biaya, bukan diisi nol secara seragam.

Terdapat 17 pasangan start/end terbalik. Start dan end ditukar dengan bukti duration positif dan timestamp completion. **Ready time merupakan field independen dan harus dipertahankan dari raw.** Pada 16 dari 17 inversi, ready memang sama dengan end mentah; pola itu tidak berlaku untuk semuanya. Memaksakan ready menjadi start hasil swap adalah penyebab bug versi lama.

## Patch final dan bukti sumber

| Field | Event diperbaiki | Dasar keputusan |
|---|---|---|
| case_type | 20 | Nilai authoritative case_master berdasarkan case_id |
| employee_id dan role | 4 | resource_master memiliki pasangan employee unik; role dari employee_master |
| resource_id dan type | 2 | employee_master memiliki pasangan resource unik; type dari resource_master |
| activity_ready_time | 1 | Pertahankan raw RAW-0000962, dikonfirmasi event pendahulu |

Keempat employee yang dipulihkan adalah EVT-0005598 → EMP-071, EVT-0004304 → EMP-030, EVT-0001776 → EMP-054, EVT-0001230 → EMP-071. Resource dipulihkan untuk EVT-0004606 → RES-055 dan EVT-0002311 → RES-071. Semua pasangan dan role kini cocok dengan master dan required role aktivitas.

**EVT-0004091 / PALM-000074.** Raw RAW-0000962 mencatat start 2026-05-09 00:11:00, end 2026-05-08 23:41:00 (terbalik), timestamp 00:11, ready **2026-05-08 19:03:00**, duration 30 dan waiting 278 menit. Hasil final: start 23:41, end/timestamp 00:11 hari berikutnya, ready 19:03. Event pendahulu Field Team Assigned / EVT-0003894 selesai pukul 19:03. Start − ready = 278 menit; duration 30 + waiting 278 > SLA 210 sehingga flag true tetap benar. Tidak ada timestamp yang ditebak.

[Audit patch per field](cleaning_patch_audit.csv) mencatat 27 perubahan field utama pada 27 event. Role/type diturunkan dari master setelah pemulihan ID. [Ringkasan sebelum dan sesudah](before_after_summary.csv) menunjukkan total waiting, processing, SLA dan baseline keuangan tetap sama; perbedaan representasi double/decimal pada CSV audit lama bukan perubahan nilai ekonomi.

## Karantina dan kelengkapan

Raw RAW-0005170 / EVT-0000623 / PALM-000105 / Buyer Remittance Matched memiliki `not-a-time` pada seluruh timestamp esensial. Tidak tersedia pasangan duplikat valid untuk memulihkannya. Event tersebut dikeluarkan dari event log analisis, tetapi disimpan dalam [quarantined_events.csv](quarantined_events.csv).

Penutupan lot EVT-0000624 mempunyai satu pendahulu remittance yang hilang karena karantina. [dependency_exceptions.csv](dependency_exceptions.csv) menyebut pengecualian itu secara eksplisit. Dependency check untuk case ini tidak boleh disajikan sebagai bukti bahwa seluruh trace lengkap. Biaya dan revenue baseline adalah total event yang dipertahankan; nilai event karantina tidak dimasukkan kembali tanpa timestamp.

Blank facility_id pada aktivitas tanpa mesin dan exception_type kosong saat exception_flag false merupakan nilai sah. FFB grade Unknown merupakan kategori provisional yang sah. Rework, inspeksi yang dilewati secara operasional, overlap jalur minyak/kernel pada resource berbeda, dan biaya tinggi tidak dihapus sebagai noise.

## Validasi rilis

[validation_results.csv](validation_results.csv) berisi 26 pemeriksaan dengan nol kegagalan: keunikan dan kelengkapan ID/cell esensial, identitas duration/waiting/end timestamp/SLA/case elapsed, seluruh atribut master case, pasangan employee-resource dan role, department/SLA aktivitas, referensi facility/grade/estate, identitas biaya dan kontribusi, lokasi pengakuan revenue, sale tepat sekali dan outcome eksklusif, pembuatan/penutupan case sekali, konservasi event sumber, keunikan master key, dependensi wajib, predecessor ready, urutan inspeksi/rework/retest/closure, serta overlap facility dan employee.

Overlap diperiksa pada capacity-one resource dengan interval start/end; akhir sama dengan awal berikutnya diperbolehkan. Nol overlap bukan bukti utilisasi efektif karena kalender staffed availability tidak tersedia. Pemeriksaan predecessor ready/closure mengakui satu pengecualian karantina di atas.

## Dampak pada Q01 sampai Q10

Q01–Q10 dihitung ulang dari rilis yang sama. Tiga varian terbesar Q01 tetap 61/23/17; throughput 19,76/8,44/17,13 jam. Q02 tetap 189 processed, 29 rejected, 12 cancelled. Q03 tetap 1.047,10 jam waiting, 3.807,23 jam processing dan 180 pelanggaran SLA. Perbaikan ready time memulihkan konsistensi kolom tanpa mengubah waiting yang sudah benar.

Q04 memakai bucket dari durasi asli tanpa batas beririsan. Q05 kini mempunyai total waiting per tahap dan beban harian fasilitas. Perubahan angka finansial Q07–Q10 berasal dari koreksi horizon OPEX, basis biaya tambahan dan pembatasan overlap manfaat, bukan perubahan baseline akibat cleaning. Skenario dan target pilot belum merupakan hasil implementasi.

## Reproduksi

Jalankan `python3 02_SQL/run_pipeline.py` dari folder mana pun dengan package duckdb tersedia. Urutan satu koneksi: 00 import → 02 cleaning → 02b patch → 03 validation → 05 export → impor ulang dan perbandingan → 06 model skenario → Q01–Q10. Pipeline menghentikan publikasi CSV jika validasi atau roundtrip gagal. Raw tidak ditimpa. [release_manifest.json](release_manifest.json) mencatat hash SHA256 raw/output, versi DuckDB, hasil gate dan jumlah pengecualian. Jalankan `python3 -m unittest discover -s tests` untuk regresi cleaning.
