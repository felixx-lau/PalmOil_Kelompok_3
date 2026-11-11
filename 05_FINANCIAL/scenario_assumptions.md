# Asumsi evaluasi investasi Palm Oil

Revisi 11 November 2026. Model seluruh program memakai cohort 24 bulan yang sama dengan baseline. CAPEX dibebankan sekali; OPEX tahunan dikalikan dua (Q07 1.200/tahun, Q08 5.000/tahun, Q09 15.000/tahun, mutu CPO 1.500/tahun). Nilai ini merupakan asumsi tugas, bukan quotation atau biaya terverifikasi lapangan. Kurs input tugas 4.384,87 IDR/MYR, tanpa penelusuran BI baru.

Baseline MYR 858.416,02 merupakan revenue dikurangi biaya operasional tercatat. Nilai To-Be adalah kontribusi sesudah biaya program dan CAPEX untuk evaluasi investasi, bukan laba akuntansi menurut jadwal depresiasi. Komponen skenario dibulatkan ke sen, lalu direkonsiliasi; FX dikalikan sebelum pembulatan ke dua desimal.

Q07: penurunan waiting 20%, avoidable share 12% dari equipment transport, bukan seluruh biaya transport. Pengurangan waktu bukan bukti penghematan kas dengan sendirinya.

Q08: pencegahan 15% relatif dari 29 reject (4,35 lot ekuivalen). Lot ini diasumsikan layak diproses dan dijual, dengan kapasitas dan demand mencukupi. Benchmark revenue memakai rata-rata processed; proxy biaya tambahan hanya aktivitas setelah penerimaan. Biaya crop, timbang, inspeksi, transport, penolakan, dan penutupan yang sudah tercatat tidak diklaim sebagai savings. Penolakan lebih dini saja tidak memenuhi asumsi pemulihan produk.

Q09: demand tetap tidak diberi tambahan revenue. Growth 15% memerlukan 28,35 lot ekuivalen tambahan dan benchmark full cost processed (termasuk crop baru). Biaya pembukaan kebun/pendanaan belum tersedia. Kapasitas tambahan tidak otomatis mempersingkat siklus, meningkatkan penjualan, atau memberikan penurunan antrean tertentu.

Mutu CPO: savings 40% hanya dari quality rework + retest CPO (MYR 20.777,51); grading kebun dikecualikan untuk membatasi overlap Q08. Allowance turun 50% terpisah. Mandatory testing tetap dijalankan. Tidak ada savings administrasi allowance dan tidak ada manfaat mutu tambahan pada lot baru Q08. Independensi respons kedua program tetap perlu diuji dalam pilot.

Gunakan `02_SQL/06_scenario_model.sql` sebagai sumber rumus, `scenario_comparison.csv` sebagai hasil, dan `sensitivity.csv` untuk variasi effectiveness. Nol efektivitas menghasilkan biaya program tanpa manfaat. Payback, NPV dan IRR belum dinyatakan karena jadwal arus kas dan discount rate tidak tersedia.
