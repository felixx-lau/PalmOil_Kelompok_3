# Ringkasan eksekutif Palm Oil

24SI1 Group 03 | Rilis 11 November 2026 | Dataset sintetis, timestamp UTC

Cleaning telah diselesaikan sesuai aturan sumber dan lolos 26 pemeriksaan. Analisis ulang mencakup Q01–Q10 dari satu CSV rilis. Temuan utama adalah biaya lot reject dan waiting yang terkonsentrasi pada episode Mei 2026. Pilot pencegahan reject dan mutu CPO mempunyai net benefit positif dalam model, dengan efektivitas serta biaya yang masih perlu diuji.

## Kualitas data dan kelengkapan

6.325 raw rows menghasilkan 6.179 event unik dalam 230 case setelah menghapus 145 duplikat ekstraksi dan mengarantina satu event remittance dengan timestamp rusak. Patch memperbaiki 20 case_type, empat employee ID, dua resource ID, serta satu ready time yang keliru tertimpa saat perbaikan inversi. Total 27 event berubah dibanding CSV sebelum patch.

Ready EVT-0004091 dipulihkan dari raw menjadi 8 Mei 2026 19:03 UTC; waktu mulai 23:41 sehingga waiting 278 menit benar. Perbaikan tidak mengubah agregat waiting, SLA atau baseline keuangan. Ekspor dan impor ulang CSV menghasilkan nol selisih. Satu dependency penutupan lot memiliki pengecualian karena event karantina; validasi bukan klaim bahwa semua trace lengkap atau akurat terhadap dunia nyata.

## Temuan Q01 sampai Q06

| Analisis | Temuan terverifikasi pada CSV rilis |
|---|---|
| Q01 varian | SQL 61/23/17 lot; throughput 19,76/8,44/17,13 jam. Urutan alternatif bukan bukti kausal efisiensi. |
| Q02 outcome | 189 processed, 29 rejected, 12 cancelled. Reject 12,61% seluruh case atau 13,30% harvested. |
| Q03 waiting | 1.047,10 jam pada Mei 2026; 180 pelanggaran SLA, 177 di kebun. Tidak membuktikan masalah kronis. |
| Q04 lead time | Rejection antar bucket 18,18/7,53/22,58/14,75%; target 3 jam dan 8% hanya target pilot. |
| Q05 fasilitas | Waiting sterilisasi 38,47 jam pada episode 8–9 Mei. Beban harian dibagi tengah malam; porsi lot bukan utilisasi. |
| Q06 mutu | Rework MYR 21.823,19; allowance MYR 20.949,08 dan administrasi MYR 421,01. Retest sah dipertahankan. |

Baseline revenue MYR 7.074.461,68, biaya MYR 6.216.045,66 dan kontribusi MYR 858.416,02 (IDR 3.764.042.653,62 pada input tugas 4.384,87 IDR/MYR). Biaya reject MYR 711.861,41 sudah masuk baseline; counterfactual MYR 953.023,09 adalah batas atas bersyarat seluruh reject pulih, bukan kerugian tambahan atau savings pasti.

<!-- pagebreak -->

## Skenario Q07 sampai Q10

Seluruh evaluasi memakai horizon cohort 24 bulan. CAPEX dibebankan sekali dan OPEX tahunan dua kali. Nilai setelah investasi berbeda dari laba akuntansi yang memakai depresiasi; model belum memuat pembiayaan atau pajak.

| Program | Net benefit MYR | Implikasi |
|---|---|---|
| Q07 scheduling | −7.482,81 | Target waiting −20%; savings hanya MYR 917,19 pada asumsi avoidable share 12% equipment. |
| Q08 reject prevention | +108.708,02 | Target −15% relatif = 4,35 lot ekuivalen. Buah harus layak diproses dan dijual. |
| Q09 fixed demand | −140.000,00 | Kapasitas tambahan tanpa tambahan sales tidak memberi revenue baru. |
| Q09 conditional growth | +95.756,24 | Memerlukan 28,35 lot ekuivalen baru, supply, demand dan biaya full processed sebagai proxy. |
| Mutu CPO | +7.785,54 | Target pencegahan rework CPO 40% dan allowance 50%; grading kebun dikecualikan dari savings. |

## Portofolio yang perlu diuji

Gabungan Q08 dan mutu CPO menghasilkan revenue tambahan MYR 173.299,45, biaya proses tambahan MYR 24.116,89, CAPEX MYR 28.000 dan OPEX dua tahun MYR 13.000, dikurangi savings MYR 8.311. Net benefit bersyarat MYR 116.493,56 atau IDR 510.809.116,44; nilai setelah investasi MYR 974.909,58.

Rekonsiliasi: revenue To-Be MYR 7.247.761,13 − biaya termasuk investasi MYR 6.272.851,55 = MYR 974.909,58. Manfaat kedua program tidak ditambahkan lagi ke Q01/Q03/Q06. Biaya crop yang sudah dialokasikan bukan savings kas otomatis.

Prioritaskan pilot pencegahan reject dengan kontrol mutu dan kelompok pembanding, lalu evaluasi mutu CPO. Jika allowance tidak turun, program mutu bernilai −MYR 2.689; titik impas sekitar penurunan 12,84% pada savings rework 40%. Efektivitas, biaya alat, kapasitas dan permintaan belum dibuktikan oleh log. Jadwal arus kas belum tersedia sehingga payback tidak ditentukan.

## Bukti dan reproduksi

Jalankan `python3 02_SQL/run_pipeline.py`; audit tersedia pada `01_DATA/validation/`, hasil query pada `02_SQL/results/`, dan model pada `02_SQL/06_scenario_model.sql`. Grafik SQL dibuat sendiri, bukan ekspor Celonis. Tangkapan layar antarmuka lama belum diverifikasi ulang asal aplikasi/filter/sorting; tampilan varian 62/23/17 dibedakan dari SQL 61/23/17. Jika rubric mewajibkan Celonis, kelompok masih perlu mengimpor rilis dan mengambil bukti aplikasi terverifikasi.
