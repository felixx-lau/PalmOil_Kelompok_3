# Analisis Palm Oil setelah final cleaning

- 24SI1 Group 03 | 11 November 2026

- Dataset sintetis; cohort Oktober 2024–September 2026; UTC.

- Q01–Q10 dihitung ulang dari satu rilis CSV.

- Temuan aktual dipisahkan dari target pilot dan skenario.

<!-- pagebreak -->

# Cleaning menyisakan 6.179 event yang dapat dianalisis

- 6.325 raw − 145 duplikat − 1 karantina = 6.179 event.

- 230 case tetap dipertahankan; rework sah tidak dihapus.

- 26 pemeriksaan lolos; ekspor dan impor ulang tanpa selisih.

- Satu trace memiliki dependency exception akibat remittance rusak.

<!-- pagebreak -->

# Patch memperbaiki 27 event dengan bukti sumber

- 20 case_type mengikuti case_master.

- 4 employee ID dan 2 resource ID pulih dari pasangan master unik.

- EVT-0004091: ready asli 19:03, start 23:41; waiting tetap 278 menit.

- Raw tidak diubah; CSV patch, karantina, dan hash tersedia.

<!-- pagebreak -->

# Q01 tiga varian terbesar tetap 61 / 23 / 17

- Throughput rata-rata 19,76 / 8,44 / 17,13 jam.

- Varian reject berhenti lebih awal; waktu singkat bukan efisiensi.

- Urutan minyak/kernel berbeda; penyebab efisiensi belum dibuktikan.

- Screenshot lama 62/23/17; angka utama selalu mengikuti SQL.

<!-- pagebreak -->

# Q01 Actual Process Map mencakup cabang dan pengulangan

- 230 batch: 12 cancelled; 218 melanjutkan panen dan transport.

- Penerimaan mill: 29 reject; 189 diterima dan diproses.

- Sesudah pressing: jalur minyak dan kernel, dengan rework/retest sah.

- Storage → dispatch → invoice → remittance → allowance bila ada → close.

<!-- pagebreak -->

# Q02 biaya reject sudah masuk baseline

- 189 processed, 29 rejected, 12 cancelled.

- Reject 12,61% dari 230 case; 13,30% dari 218 harvested lot.

- Biaya reject MYR 711.861,41; tidak dikurangkan lagi dari baseline.

- MYR 953.023,09 adalah batas atas counterfactual seluruh reject pulih.

<!-- pagebreak -->

# Q03 waiting terkonsentrasi pada Mei 2026

- Total waiting 1.047,10 jam; processing 3.807,23 jam.

- 180 pelanggaran SLA, 177 pada tahap kebun.

- 67 transport start pada 8–9 Mei: 23 dan 44 pengiriman.

- Episode lonjakan belum membuktikan antrean kronis atau akar sebab.

<!-- pagebreak -->

# Q04 target 3 jam dan 8 persen adalah pilot

- Rejection rate bucket: 18,18 / 7,53 / 22,58 / 14,75%.

- Hubungan tidak monoton; asosiasi belum membuktikan sebab.

- Lead time dihitung dari akhir panen sampai awal timbang masuk.

- Target pilot: lead time maksimal 3 jam dan reject maksimal 8%.

<!-- pagebreak -->

# Q05 beban harian memperjelas episode sterilisasi

- Sterilisasi: rata-rata proses 81,20 menit; waiting 12,21 menit.

- Waiting total 38,47 jam pada 8–9 Mei.

- FAC-029 9 Mei: 20,63 jam = 85,97% dari 24 jam kalender.

- Q05.sql kini memuat waiting per tahap dan beban harian semua fasilitas.

<!-- pagebreak -->

# Q06 rework sah tetap menjadi bagian analisis

- 76 eksekusi rework; biaya MYR 21.823,19.

- Allowance MYR 20.949,08; administrasi MYR 421,01.

- Total beban tercatat MYR 43.193,28 sudah masuk baseline.

- Penghematan perlu pencegahan kegagalan; mandatory retest tetap berjalan.

<!-- pagebreak -->

# Q07 penjadwalan perlu diuji dengan biaya nyata

- Target waiting turun 20% setara 25,88 jam; belum realisasi.

- Savings MYR 917,19 = equipment × 12% avoidable × 20%.

- CAPEX 6.000 + OPEX 2.400 untuk 24 bulan.

- Net benefit −MYR 7.482,81; evaluasi alternatif berbiaya rendah.

<!-- pagebreak -->

# Q08 pencegahan reject menjadi prioritas pilot

- Target penurunan relatif 15% = 4,35 lot ekuivalen.

- Revenue tambahan MYR 162.824,91; proses tambahan MYR 24.116,89.

- CAPEX 20.000 + OPEX 10.000 untuk 24 bulan.

- Net benefit bersyarat +MYR 108.708,02; sunk crop bukan savings baru.

<!-- pagebreak -->

# Q09 tambahan kapasitas membutuhkan supply dan demand

- Fixed demand: revenue baru nol; net benefit −MYR 140.000.

- Growth: 28,35 lot ekuivalen baru; net benefit +MYR 95.756,24.

- Pertumbuhan memakai proxy biaya penuh, termasuk crop lot baru.

- Kapasitas +15% tidak otomatis memberi antrean tertentu atau sales baru.

<!-- pagebreak -->

# Q10 portofolio memberi manfaat bersyarat

- Q08 + mutu CPO: net benefit MYR 116.493,56.

- CAPEX 28.000; OPEX dua tahun 13.000.

- Savings mutu 8.311 hanya CPO rework/retest; grading kebun dikecualikan.

- Revenue 7.247.761,13 − biaya termasuk investasi 6.272.851,55 = 974.909,58.

<!-- pagebreak -->

# Keputusan investasi memerlukan bukti pilot

- Mutu CPO: net benefit +7.785,54 pada allowance −50% dan rework −40%.

- Tanpa penurunan allowance: −2.689; impas allowance sekitar 12,84%.

- Efektivitas, kapasitas, harga dan demand perlu divalidasi.

- Payback belum ditentukan karena jadwal arus kas tidak tersedia.

<!-- pagebreak -->

# Bukti analisis dapat direproduksi

- python3 02_SQL/run_pipeline.py lalu python3 -m unittest discover -s tests

- Grafik SQL dibuat sendiri; bukan ekspor Celonis.

- Tangkapan layar lama: asal aplikasi/filter/sorting belum diverifikasi ulang.

- Sumber: laporan cleaning, hasil Q01–Q10, model skenario dan manifest bukti.
