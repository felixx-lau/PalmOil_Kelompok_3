import os
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY

# -------------------------------------------------------------
# 1. BUILD EXECUTIVE SUMMARY PDF (Portrait, 2 Pages)
# -------------------------------------------------------------
def build_executive_summary():
    pdf_path = "24SI1_Group03_Palm_Oil/07_EXECUTIVE_SUMMARY/executive_summary.pdf"
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )
    
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#1b4332'),
        alignment=TA_LEFT
    )
    subtitle_style = ParagraphStyle(
        'DocSub',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#495057')
    )
    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=colors.HexColor('#1b4332'),
        spaceBefore=6,
        spaceAfter=3
    )
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor('#212529'),
        alignment=TA_JUSTIFY,
        spaceAfter=4
    )
    callout_style = ParagraphStyle(
        'Callout',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor('#081c15'),
        alignment=TA_LEFT
    )
    table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor('#212529')
    )
    table_header = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.white
    )

    story = []

    # Header Banner
    story.append(Paragraph("EXECUTIVE SUMMARY: STRATEGIS BISNIS & PROCESS MINING", title_style))
    story.append(Paragraph("Tanjung Palma Agro-Industrial Estate • FFB Harvest-to-CPO Dispatch & Collection • 24SI1 Group 03", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor('#2d6a4f'), spaceBefore=4, spaceAfter=6))

    # 1. Business Context & Challenge
    story.append(Paragraph("1. Konteks Bisnis & Tantangan Manajemen", h1_style))
    story.append(Paragraph(
        "Tanjung Palma Agro-Industrial Estate mengelola perkebunan kelapa sawit terintegrasi dan pabrik Crude Palm Oil (CPO). "
        "Evaluasi dilakukan terhadap kinerja 230 lot panen (*Fresh Fruit Bunches* / FFB) selama periode simulasi Oktober 2024 hingga September 2026. "
        "Tantangan utama manajemen adalah mengatasi tingginya laju penolakan (*rejection*) buah di pintu pabrik, antrean operasional kebun, "
        "serta klaim penalti mutu pembeli tanpa mengorbankan standar kualitas dan keselamatan.", body_style
    ))

    # 2. Dataset & Methodological Audit
    story.append(Paragraph("2. Metodologi Data Preparation & Validasi Kualitas Data", h1_style))
    story.append(Paragraph(
        "Analisis menggunakan DuckDB SQL dan Celonis Process Mining terhadap dataset transaksi riil (6.325 baris awal). "
        "Melalui proses audit kualitas data yang ketat: (a) 145 baris duplikat ekstraksi dieleminasi, (b) 1 catatan korup ('not-a-time') dikarantina, "
        "(c) 17 rekaman dengan timestamp terbalik (*start > end*) diperbaiki secara kronologis, dan (d) format mata uang distandardisasi. "
        "Hasil pembersihan menghasilkan <b>6.179 event valid</b> dan <b>230 lot tuntas</b> yang 100% konsisten dengan data master.", body_style
    ))

    # 3. Financial Baseline & Kurs Bank Indonesia
    story.append(Paragraph("3. Baseline Finansial & Kurs Referensi BI (13 Oktober 2026)", h1_style))
    story.append(Paragraph(
        "Berdasarkan Kurs Transaksi Bank Indonesia per 13 Oktober 2026 (Kurs Jual: 4.408,94; Kurs Beli: 4.360,80), ditetapkan "
        "<b>Reference Rate (Midpoint) = 4.384,87 IDR per 1 MYR</b> sebagai konversi analitis tunggal. "
        "Kondisi As-Is mencatat pendapatan bersih <b>7.074.461,68 MYR (31,02 Miliar IDR)</b>, biaya operasional <b>6.216.045,66 MYR (27,26 Miliar IDR)</b>, "
        "dan laba kontribusi bersih <b>858.416,02 MYR (3,76 Miliar IDR)</b> dengan rata-rata biaya per lot sebesar 27.026,29 MYR.", body_style
    ))

    # Baseline Table
    fin_data = [
        [Paragraph("Indikator Finansial", table_header), Paragraph("Nilai MYR (As-Is)", table_header), Paragraph("Nilai IDR (Kurs BI 4.384,87)", table_header), Paragraph("Deskripsi Operasional", table_header)],
        [Paragraph("Gross Sales Revenue", table_cell), Paragraph("7.095.410,76 MYR", table_cell), Paragraph("31.112.450.410,61 IDR", table_cell), Paragraph("Penjualan pada CPO Dispatch Confirmed", table_cell)],
        [Paragraph("Sales Allowances (Deduction)", table_cell), Paragraph("-20.949,08 MYR", table_cell), Paragraph("-91.857.117,14 IDR", table_cell), Paragraph("Klaim penalti mutu dari pembeli (FFA/Moisture)", table_cell)],
        [Paragraph("Net Realized Revenue", table_cell), Paragraph("7.074.461,68 MYR", table_cell), Paragraph("31.020.593.293,47 IDR", table_cell), Paragraph("Pendapatan bersih yang direalisasikan kas", table_cell)],
        [Paragraph("Sunk Crop Feedstock Cost", table_cell), Paragraph("4.907.350,72 MYR", table_cell), Paragraph("21.518.095.460,91 IDR", table_cell), Paragraph("Biaya budidaya tanam yang hangus saat panen", table_cell)],
        [Paragraph("Downstream Milling & Transport", table_cell), Paragraph("1.308.694,94 MYR", table_cell), Paragraph("5.738.457.237,90 IDR", table_cell), Paragraph("Biaya logistik truk, perebusan, kempa, dan lab", table_cell)],
        [Paragraph("Total Operational Cost", table_cell), Paragraph("6.216.045,66 MYR", table_cell), Paragraph("27.256.552.698,81 IDR", table_cell), Paragraph("Total biaya operasional seluruh 230 lot", table_cell)],
        [Paragraph("<b>Profit Contribution</b>", table_cell), Paragraph("<b>858.416,02 MYR</b>", table_cell), Paragraph("<b>3.764.040.594,66 IDR</b>", table_cell), Paragraph("<b>Margin kontribusi bersih perusahaan</b>", table_cell)]
    ]
    t1 = Table(fin_data, colWidths=[110, 85, 115, 230])
    t1.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#2d6a4f')),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dee2e6')),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#f8f9fa')])
    ]))
    story.append(t1)
    story.append(Spacer(1, 6))

    # 4. Key Diagnostic Findings
    story.append(Paragraph("4. Temuan Kunci Diagnostik Proses (Key Findings)", h1_style))
    story.append(Paragraph(
        "• <b>Kebocoran Biaya Akibat Lot Ditolak (Cost Leakage)</b>: Sebanyak 29 lot (12,61%) ditolak di gerbang intake pabrik. "
        "Karena biaya tanam (sunk crop cost sebesar MYR 23.277/lot) dan angkut truk telah dikeluarkan, penolakan ini menimbulkan "
        "<b>kerugian langsung sebesar 711.861,41 MYR (3,12 Miliar IDR)</b> ditambah kehilangan potensi laba sebesar 241.161 MYR (Total dampak: 4,18 Miliar IDR).<br/>"
        "• <b>Konsentrasi Keterlambatan di Kebun</b>: Sebanyak 98,33% (177 dari 180) pelanggaran SLA terkonsentrasi di tahap panen kebun "
        "(terutama aktivitas *Harvest Batch Created*, *Ripeness Assessed*, dan *Field Team Assigned*), menyerap 818 jam antrean.<br/>"
        "• <b>Bottleneck Fasilitas Pabrik</b>: Stasiun Sterilisasi (*FFB Sterilization*) adalah bottleneck utama pabrik dengan siklus 81,2 menit/lot "
        "dan total waktu antre 38,5 jam. Ketimpangan beban terjadi karena unit primer (FAC-029) menangani 79,4% volume, memicu lonjakan antre pada unit sekunder.<br/>"
        "• <b>Beban Pengerjaan Ulang & Penalti</b>: Tercatat 27 aktivitas perbaikan mutu minyak (*CPO Quality Rework*) menelan biaya MYR 18.469,49, "
        "27 uji lab ulang (MYR 2.308,02), dan 14 klaim potongan harga pembeli sebesar -MYR 20.949,08 (Total beban kualitas: 43.193,28 MYR / 189,4 Juta IDR).",
        body_style
    ))

    story.append(PageBreak())

    # PAGE 2
    story.append(Paragraph("5. Evaluasi Skenario Perbaikan & Hasil What-If Analysis", h1_style))
    story.append(Paragraph(
        "Empat inisiatif perbaikan dievaluasi secara kuantitatif berdasarkan kriteria *Net Financial Benefit*, biaya investasi (CAPEX), "
        "biaya operasional (OPEX), dan tingkat kelayakan implementasi (*implementability*):", body_style
    ))

    # Scenario Table
    scen_data = [
        [Paragraph("Program Inisiatif", table_header), Paragraph("Skenario Operasional", table_header), Paragraph("CAPEX + OPEX", table_header), Paragraph("Net Benefit (MYR)", table_header), Paragraph("Net Benefit (IDR)", table_header), Paragraph("Prioritas & Rekomendasi", table_header)],
        [Paragraph("<b>Q08 Early FFB Grading</b>", table_cell), Paragraph("Penurunan reject 15% via uji kematangan di TPH", table_cell), Paragraph("MYR 25.000", table_cell), Paragraph("<b>+113.151,43</b>", table_cell), Paragraph("<b>+496.154.378,13</b>", table_cell), Paragraph("<b>PRIORITAS 1 (Sangat Layak)</b>", table_cell)],
        [Paragraph("<b>Q06 Quality Stabilization</b>", table_cell), Paragraph("Kurangi 50% allowance & 40% retest lab", table_cell), Paragraph("MYR 9.500", table_cell), Paragraph("<b>+9.703,82</b>", table_cell), Paragraph("<b>+42.550.115,89</b>", table_cell), Paragraph("<b>PRIORITAS 2 (Sangat Layak)</b>", table_cell)],
        [Paragraph("Q07 Transport Scheduling", table_cell), Paragraph("Kurangi 20% waktu antre truk pengangkut", table_cell), Paragraph("MYR 7.200", table_cell), Paragraph("-3.910,00", table_cell), Paragraph("-17.144.841,70", table_cell), Paragraph("Tolak (Gaji supir tetap/rugi kas)", table_cell)],
        [Paragraph("Q09 Mill Capacity (Fixed)", table_cell), Paragraph("Ekspansi bejana sterilizer 15% (demand tetap)", table_cell), Paragraph("MYR 125.000", table_cell), Paragraph("-125.000,00", table_cell), Paragraph("-548.108.750,00", table_cell), Paragraph("Tolak Keras (Idle capacity/rugi)", table_cell)],
        [Paragraph("<b>Portofolio Rekomendasi (P1+P2)</b>", table_cell), Paragraph("<b>Kombinasi Terpadu Kebun & Pabrik</b>", table_cell), Paragraph("<b>MYR 34.500</b>", table_cell), Paragraph("<b>+122.855,25</b>", table_cell), Paragraph("<b>+538.704.294,02</b>", table_cell), Paragraph("<b>REKOMENDASI EKSEKUTIF</b>", table_cell)]
    ]
    t2 = Table(scen_data, colWidths=[95, 120, 65, 80, 95, 85])
    t2.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#1b4332')),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dee2e6')),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#f8f9fa')])
    ]))
    story.append(t2)
    story.append(Spacer(1, 6))

    # 6. Comparison As-Is vs No-Action vs To-Be
    story.append(Paragraph("6. Perbandingan Menyeluruh As-Is vs. No-Action vs. To-Be", h1_style))
    story.append(Paragraph(
        "• <b>Skenario No-Action (Status Quo)</b>: Membiarkan kondisi saat ini berarti merelakan kerugian rutin akibat penolakan buah sebesar "
        "<b>711.861,41 MYR (~3,12 Miliar IDR)</b> dan denda mutu pembeli sebesar 20.949 MYR per siklus panen. Laba kontribusi stagnan pada 858.416,02 MYR.<br/>"
        "• <b>Skenario To-Be (Implementasi P1 + P2)</b>: Penerimaan pendapatan bersih meningkat menjadi <b>7.247.761,11 MYR (31,78 Miliar IDR)</b>. "
        "Laba kontribusi melonjak menjadi <b>981.271,27 MYR (4,30 Miliar IDR)</b>, memberikan kenaikan laba bersih sebesar <b>+14,31% (+538,70 Juta IDR)</b> "
        "dengan tingkat ROI investasi mencapai 356,1% dan periode pengembalian modal (*payback period*) kurang dari 6 bulan.", body_style
    ))

    # 7. Management Action Plan & Strategic Decisions
    story.append(Paragraph("7. Keputusan Strategis & Rencana Aksi Manajemen", h1_style))
    story.append(Paragraph(
        "1. <b>Eksekusi Program Prioritas 1 (Q08 - Grading Kebun di TPH)</b>: Segera alokasikan anggaran modal sebesar MYR 20.000 untuk pengadaan 4 unit "
        "scanner kematangan portabel NIR dan pelatihan 15 mandor panen di seluruh afdeling. Geser gerbang penolakan ke TPH agar buah mentah/rusak tidak diangkut ke mill.<br/>"
        "2. <b>Eksekusi Program Prioritas 2 (Q06 - Stabilisasi Suhu Clarifier & Pemurnian)</b>: Alokasikan MYR 8.000 untuk pemasangan kontrol sensor suhu otomatis "
        "pada centrifuge dan vacuum dryer guna mencegah kenaikan FFA dan kadar air yang memicu sales allowances dari pembeli.<br/>"
        "3. <b>Tolak Pengadaan Software Truk Berbayar (Q07) & Pembelian Bejana Sterilizer Baru (Q09)</b>: Jangan mengeluarkan modal untuk ekspansi fisik mesin "
        "sterilisasi selama pasokan areal kebun belum bertambah. Terapkan penataan jadwal perebusan internal secara gratis.<br/>"
        "4. <b>Mitigasi Risiko Lapangan</b>: Tetapkan skema insentif kualitas bagi pemanen yang berhasil mempertahankan persentase penolakan di bawah 3%, "
        "serta lakukan audit kalibrasi instrumen laboratorium secara berkala setiap 6 bulan.", body_style
    ))
    
    story.append(Spacer(1, 8))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#adb5bd'), spaceBefore=2, spaceAfter=4))
    story.append(Paragraph("Disetujui oleh: <b>Executive Board Tanjung Palma Agro-Industrial Estate</b> • 24SI1 Group 03 • 26 Oktober 2026", subtitle_style))

    doc.build(story)
    print("Executive Summary PDF created successfully.")

# -------------------------------------------------------------
# 2. BUILD PRESENTATION SLIDES PDF (Landscape, 16 Slides)
# -------------------------------------------------------------
def build_presentation_slides():
    pdf_path = "24SI1_Group03_Palm_Oil/06_PRESENTATION/slides.pdf"
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=landscape(letter),
        rightMargin=28,
        leftMargin=28,
        topMargin=24,
        bottomMargin=24
    )

    styles = getSampleStyleSheet()

    slide_title = ParagraphStyle(
        'SlideTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=19,
        textColor=colors.HexColor('#1b4332')
    )
    slide_cat = ParagraphStyle(
        'SlideCat',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.HexColor('#2d6a4f')
    )
    slide_body = ParagraphStyle(
        'SlideBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=12.5,
        textColor=colors.HexColor('#212529')
    )
    slide_bullet = ParagraphStyle(
        'SlideBullet',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor('#212529'),
        leftIndent=12,
        spaceAfter=3
    )
    th_style = ParagraphStyle(
        'TH',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=9,
        textColor=colors.white
    )
    td_style = ParagraphStyle(
        'TD',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7,
        leading=8.5,
        textColor=colors.HexColor('#212529')
    )

    slides_content = []

    def make_slide(title, category, content_flowables, img_path=None):
        slide = []
        slide.append(Paragraph(category.upper(), slide_cat))
        slide.append(Paragraph(title, slide_title))
        slide.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor('#2d6a4f'), spaceBefore=2, spaceAfter=8))
        
        if img_path and os.path.exists(img_path):
            img = Image(img_path, width=4.5*inch, height=2.4*inch)
            t_layout = Table([
                [content_flowables, img]
            ], colWidths=[5.0*inch, 4.8*inch])
            t_layout.setStyle(TableStyle([
                ('VALIGN', (0,0), (-1,-1), 'TOP'),
                ('LEFTPADDING', (0,0), (-1,-1), 0),
                ('RIGHTPADDING', (0,0), (-1,-1), 0),
                ('TOPPADDING', (0,0), (-1,-1), 0),
                ('BOTTOMPADDING', (0,0), (-1,-1), 0)
            ]))
            slide.append(t_layout)
        else:
            for item in content_flowables:
                slide.append(item)
                
        slide.append(Spacer(1, 10))
        slide.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor('#ced4da'), spaceBefore=4, spaceAfter=2))
        slide.append(Paragraph("24SI1 • GROUP 03 • Palm Oil Agriculture & Processing • Tanjung Palma Agro-Industrial Estate", ParagraphStyle('Footer', fontName='Helvetica', fontSize=6.5, textColor=colors.HexColor('#6c757d'))))
        return slide

    # SLIDE 1: Title & Company Context
    s1_items = [
        Spacer(1, 15),
        Paragraph("<b>Evaluasi Kinerja FFB Harvest-to-CPO Dispatch & Collection</b>", ParagraphStyle('TitleLarge', fontName='Helvetica-Bold', fontSize=18, leading=22, textColor=colors.HexColor('#1b4332'))),
        Spacer(1, 10),
        Paragraph("<b>Tanjung Palma Agro-Industrial Estate</b> adalah perkebunan sawit dan pabrik kelapa sawit terintegrasi. "
                  "Simulasi mencakup 230 processing lot yang dipanen pada periode Oktober 2024 – September 2026.", slide_body),
        Spacer(1, 8),
        Paragraph("• <b>Case Notion</b>: Satu batch panen TBS (Fresh Fruit Bunches) yang ditelusuri sebagai lot pengolahan hingga pengapalan CPO.", slide_bullet),
        Paragraph("• <b>Business Challenge</b>: Mengurangi lonjakan reject buah di pabrik dan memangkas waktu tunggu logistik kebun tanpa menurunkan standar mutu CPO komersial.", slide_bullet),
        Paragraph("• <b>Alur Metodologis Wajib</b>: Raw CSV $\\rightarrow$ Profiling $\\rightarrow$ Cleaning $\\rightarrow$ Validation $\\rightarrow$ Cleaned Export $\\rightarrow$ Celonis Analysis $\\rightarrow$ Business Case.", slide_bullet),
        Spacer(1, 10),
        Paragraph("Tim Konsultan: <b>24SI1 • GROUP 03</b> | Waktu: 15 Menit Presentasi + 5 Menit Q&A", ParagraphStyle('Meta', fontName='Helvetica-Bold', fontSize=9, textColor=colors.HexColor('#2d6a4f')))
    ]
    slides_content.append(make_slide("Evaluasi Proses Bisnis Minyak Sawit Terintegrasi", "01 / Company & Project Context", s1_items))

    # SLIDE 2: Data Quality & Cleaning
    s2_items = [
        Paragraph("<b>Audit & Pembersihan Data Transaksi (DuckDB SQL):</b>", slide_body),
        Paragraph("• <b>Volume Awal</b>: 6.325 baris data mentah (*raw event log*).", slide_bullet),
        Paragraph("• <b>Deduplikasi Sumber (145 baris dibersihkan)</b>: Menghapus 145 baris ekstraksi berulang dari 143 event_id ganda; seluruh pengerjaan ulang (*rework*) sah memiliki event_id unik dan dipertahankan 100%.", slide_bullet),
        Paragraph("• <b>Karantina Data Korup (1 baris)</b>: Record RAW-0005170 (EVT-0000623, Buyer Remittance Matched) dikarantina karena timestamp bernilai 'not-a-time'.", slide_bullet),
        Paragraph("• <b>Perbaikan Timestamp Terbalik (17 baris)</b>: Menukar kolom start_time dan end_time yang terbalik saat ekstraksi sehingga konsisten dengan durasi dan timestamp end.", slide_bullet),
        Paragraph("• <b>Pembersihan Simbol Keuangan</b>: Menghapus karakter teks 'RM' / 'MYR' pada 17 nilai finansial dan merekonstruksi 3 nilai material_cost yang hilang.", slide_bullet),
        Paragraph("• <b>Hasil Akhir</b>: <b>6.179 event bersih</b> dan <b>230 case lot valid</b> yang 100% cocok dengan case_master.", slide_bullet)
    ]
    slides_content.append(make_slide("Data Preparation, Data Quality & Quarantine Log", "02 / Data Engineering", s2_items))

    # SLIDE 3: Financial Baseline & Kurs BI
    s3_table = [
        [Paragraph("Metrik Finansial", th_style), Paragraph("Nilai MYR (As-Is)", th_style), Paragraph("Nilai IDR (13 Okt 2026)", th_style)],
        [Paragraph("Total Lot Kasus", td_style), Paragraph("230 Lot", td_style), Paragraph("230 Lot", td_style)],
        [Paragraph("Total Event Bersih", td_style), Paragraph("6.179 Event", td_style), Paragraph("6.179 Event", td_style)],
        [Paragraph("Gross Revenue", td_style), Paragraph("7.095.410,76 MYR", td_style), Paragraph("31.112.450.410,61 IDR", td_style)],
        [Paragraph("Sales Allowances", td_style), Paragraph("-20.949,08 MYR", td_style), Paragraph("-91.857.117,14 IDR", td_style)],
        [Paragraph("<b>Net Realized Revenue</b>", td_style), Paragraph("<b>7.074.461,68 MYR</b>", td_style), Paragraph("<b>31.020.593.293,47 IDR</b>", td_style)],
        [Paragraph("Total Operational Cost", td_style), Paragraph("6.216.045,66 MYR", td_style), Paragraph("27.256.552.698,81 IDR", td_style)],
        [Paragraph("<b>Profit Contribution</b>", td_style), Paragraph("<b>858.416,02 MYR</b>", td_style), Paragraph("<b>3.764.040.594,66 IDR</b>", td_style)],
        [Paragraph("Cost per Lot (Average)", td_style), Paragraph("27.026,29 MYR", td_style), Paragraph("118.506.750,86 IDR", td_style)]
    ]
    t_s3 = Table(s3_table, colWidths=[120, 100, 120])
    t_s3.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#2d6a4f')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dee2e6')),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#f8f9fa')])
    ]))
    s3_items = [
        Paragraph("<b>Konvensi Kurs Bank Indonesia (13 Oktober 2026):</b>", slide_body),
        Paragraph("• Sumber Resmi: Bank Indonesia (Kurs Transaksi BI).", slide_bullet),
        Paragraph("• Kurs Jual: 4.408,94 IDR | Kurs Beli: 4.360,80 IDR.", slide_bullet),
        Paragraph("• <b>Reference Rate (Midpoint) = 4.384,87 IDR per 1 MYR</b>.", slide_bullet),
        Spacer(1, 4),
        t_s3
    ]
    slides_content.append(make_slide("Baseline Finansial & Standar Kurs Bank Indonesia", "03 / Financial Conventions", s3_items))

    # SLIDE 4: Q01 Process Discovery & Variants
    s4_items = [
        Paragraph("<b>Tiga Varian Alur Proses Dominan:</b>", slide_body),
        Paragraph("• <b>Varian 1 (Happy Path - 61 Lot / 26,52%)</b>: Alur standard panen hingga pengapalan CPO. Throughput: 19,76 jam, Biaya: MYR 28.263,59, Kontribusi: <b>+9.020,64 MYR/lot</b>.", slide_bullet),
        Paragraph("• <b>Varian 2 (Early Mill Rejection - 23 Lot / 10,00%)</b>: Buah dipanen & diangkut ke pabrik, namun ditolak di intake. Throughput: 8,44 jam, Kontribusi: <b>-23.914,16 MYR/lot</b> (Total rugi: <b>-550.025,68 MYR</b>).", slide_bullet),
        Paragraph("• <b>Varian 3 (Agile Dispatched - 17 Lot / 7,39%)</b>: Operasi pemurnian minyak & pemisahan kernel berjalan paralel. Throughput lebih cepat (17,13 jam), Kontribusi tertinggi: <b>+9.270,96 MYR/lot</b>.", slide_bullet),
        Paragraph("• <b>Implikasi Utilisasi</b>: Varian 2 menyerap 10% jam truk dan jembatan timbang namun menghasilkan 0 output bagi stasiun perebusan dan press.", slide_bullet)
    ]
    slides_content.append(make_slide("Q01 · Harvest-to-CPO Process Discovery & Variants", "04 / Descriptive Analysis", s4_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q01/Q01_dominant_variants_comparison.png"))

    # SLIDE 5: Q02 FFB Outcomes & Cost Leakage
    s5_items = [
        Paragraph("<b>Hasil Akhir Lot & Kebocoran Biaya (Cost Leakage):</b>", slide_body),
        Paragraph("• <b>Processed / Dispatched (189 Lot / 82,17%)</b>: Menghasilkan 100% pendapatan (MYR 7,07 Juta) dan laba kontribusi <b>+1.571.708,26 MYR</b>.", slide_bullet),
        Paragraph("• <b>Rejected Lots (29 Lot / 12,61%)</b>: Mengakibatkan kebocoran modal langsung sebesar <b>-711.861,41 MYR (-3,12 Miliar IDR)</b>.", slide_bullet),
        Paragraph("• <b>Cancelled Lots (12 Lot / 5,22%)</b>: Dibatalkan sebelum panen, biaya minimal (MYR 1.430,83 untuk perencanaan).", slide_bullet),
        Paragraph("• <b>Sunk Feedstock Risk</b>: 94,8% biaya lot reject adalah biaya tanam buah yang hangus saat panen (MYR 675.040,72).", slide_bullet),
        Paragraph("• <b>Total Economic Damage</b>: Biaya riil ditambah peluang laba hilang mencapai <b>953.023,09 MYR (4,18 Miliar IDR)</b>.", slide_bullet)
    ]
    slides_content.append(make_slide("Q02 · FFB Outcomes & Cost Leakage Analysis", "05 / Descriptive Analysis", s5_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q02/Q02_outcomes_cost_breakdown.png"))

    # SLIDE 6: Q03 Plantation-to-Mill Performance
    s6_items = [
        Paragraph("<b>Kinerja Antrean Tahapan & Pelanggaran SLA:</b>", slide_body),
        Paragraph("• <b>Konsentrasi SLA Kebun</b>: Sebanyak <b>98,33% (177 dari 180)</b> pelanggaran SLA di seluruh perusahaan terjadi pada tahap <b>Plantation / Harvesting</b>.", slide_bullet),
        Paragraph("• <b>Penyumbang Antrean Terbesar</b>: Tahap kebun mengakumulasi 818 jam waktu antre (rata-rata 35,93 menit per aktivitas).", slide_bullet),
        Paragraph("• <b>Aktivitas Paling Kritis</b>: Harvest Batch Created (58 viol), Palm Ripeness Assessed (46 viol), dan FFB Field Grading (43 viol).", slide_bullet),
        Paragraph("• <b>Stabilitas Tahap Pabrik</b>: Tahap Milling dan Weighbridge mencatat 100% kepatuhan SLA (0 pelanggaran).", slide_bullet),
        Paragraph("• <b>Prioritas Utama</b>: Koordinasi penugasan regu panen dan penilai kematangan di kebun adalah prioritas perbaikan #1.", slide_bullet)
    ]
    slides_content.append(make_slide("Q03 · Plantation-to-Mill Performance & SLA", "06 / Descriptive Analysis", s6_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q03/Q03_sla_violations_and_wait_times.png"))

    # SLIDE 7: Q04 Time-to-Mill & FFB Quality
    s7_items = [
        Paragraph("<b>Lead Time Panen-ke-Pabrik vs. Penolakan Buah:</b>", slide_body),
        Paragraph("• <b>Waktu Tempuh Optimal (2–3 Jam)</b>: Mencatat tingkat penolakan terendah, yaitu hanya <b>7,53%</b>.", slide_bullet),
        Paragraph("• <b>Lonjakan Penolakan (>3 Jam)</b>: Pada durasi 3–4 jam, penolakan melonjak drastis hingga <b>22,58%</b>.", slide_bullet),
        Paragraph("• <b>Mekanisme Biologis</b>: Enzim lipase teraktivasi akibat luka potong buah; paparan panas saat transit mempercepat hidrolisis menjadi FFA.", slide_bullet),
        Paragraph("• <b>Ketiadaan Kausalitas Tunggal</b>: Lot yang diangkut sangat cepat (<2 jam) tetap ditolak sebesar 18,18%, membuktikan adanya faktor independen hulu: <b>fraksi kematangan buah saat dipetik di kebun</b>.", slide_bullet),
        Paragraph("• <b>Kerugian Total Reject</b>: <b>711.861,41 MYR (3,12 Miliar IDR)</b>.", slide_bullet)
    ]
    slides_content.append(make_slide("Q04 · Time-to-Mill Lead Time & FFB Quality", "07 / Diagnostic Analysis", s7_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q04/Q04_time_to_mill_vs_rejection.png"))

    # SLIDE 8: Q05 Milling Facility Bottlenecks
    s8_items = [
        Paragraph("<b>Identifikasi Bottleneck Fasilitas Pabrik:</b>", slide_body),
        Paragraph("• <b>Bottleneck Utama Pabrik (#1)</b>: <b>FFB Sterilization</b> (Perebusan Uap), menyerap 255,77 jam operasi (81,2 menit/lot) dan 38,47 jam antrean.", slide_bullet),
        Paragraph("• <b>Bottleneck Sekunder (#2 & #3)</b>: Kempa Minyak (*Pressing*, 67,8 min) dan Klarifikasi (*Clarification*, 61,8 min).", slide_bullet),
        Paragraph("• <b>Ketimpangan Beban Sterilizer</b>: Unit FAC-029 menangani 79,4% lot (antre 6,4 min). Ketika overload, antrean pada unit sekunder FAC-030 dan FAC-031 melonjak hingga <b>34,6 menit/lot</b>.", slide_bullet),
        Paragraph("• <b>Jembatan Timbang Lancar</b>: Weighbridge bukan bottleneck (rata-rata antre hanya 0,27 menit/lot).", slide_bullet),
        Paragraph("• <b>Peluang Kapasitas</b>: Waktu antre 38,5 jam di sterilizer setara dengan potensi kapasitas untuk mengolah ~28 lot tambahan.", slide_bullet)
    ]
    slides_content.append(make_slide("Q05 · Milling Facility Bottlenecks & Capacity", "08 / Diagnostic Analysis", s8_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q05/Q05_milling_facility_bottlenecks.png"))

    # SLIDE 9: Q06 Quality Rework vs Duplicates & Allowances
    s9_items = [
        Paragraph("<b>Pembedaan Rework Sah vs. Duplikasi Data:</b>", slide_body),
        Paragraph("• <b>Data Duplicates (Technical Defect)</b>: 145 baris ekstraksi ganda dengan event_id dan waktu sama; telah dibersihkan.", slide_bullet),
        Paragraph("• <b>Legitimate Rework (Physical Retest)</b>: Eksekusi fisik ulang yang sah dengan event_id baru dan waktu baru untuk menjaga kepatuhan mutu (tagged rework_flag = true).", slide_bullet),
        Paragraph("• <b>Biaya Rework Tercatat (MYR 21.823,19)</b>: CPO Quality Rework (27 kasus = MYR 18.469,49), Uji Ulang Lab (27 kasus = MYR 2.308,02), dan Grading Kebun (22 kasus = MYR 1.045,68).", slide_bullet),
        Paragraph("• <b>Klaim Denda Pembeli (*Sales Allowances*)</b>: 14 lot mengalami potongan harga faktur akibat penalti mutu sebesar <b>-20.949,08 MYR</b>.", slide_bullet),
        Paragraph("• <b>Total Beban Kegagalan Mutu</b>: <b>43.193,28 MYR (189,4 Juta IDR)</b>.", slide_bullet)
    ]
    slides_content.append(make_slide("Q06 · Quality Rework & Commercial Sales Allowances", "09 / Diagnostic Analysis", s9_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q06/Q06_rework_and_sales_allowances.png"))

    # SLIDE 10: Q07 Transport Scheduling Scenario
    s10_items = [
        Paragraph("<b>Skenario Penurunan 20% Waktu Tunggu Transportasi:</b>", slide_body),
        Paragraph("• <b>Manfaat Waktu</b>: Menghemat 25,88 jam antrean truk (dari 129,4 jam menjadi 103,5 jam), atau ~7,1 menit per rit pengangkutan.", slide_bullet),
        Paragraph("• <b>Manfaat Biaya Kas (Avoidable Cost)</b>: Hanya 12% dari biaya truk yang dapat dihemat (BBM mesin menyala diam / idle fuel = MYR 3.290,00). Supir truk adalah karyawan bulanan tetap.", slide_bullet),
        Paragraph("• <b>Manfaat Kualitas</b>: Tidak dapat diasumsikan tanpa indikator empiris; penghematan 7 menit tidak signifikan terhadap laju FFA.", slide_bullet),
        Paragraph("• <b>Beban Biaya Sistem</b>: Biaya software dispatch (MYR 6.000) + OPEX (MYR 1.200) = MYR 7.200.", slide_bullet),
        Paragraph("• <b>Hasil Finansial Bersih</b>: <b>Net Loss sebesar -3.910,00 MYR (-17,14 Juta IDR)</b>. Jangan jalankan sistem berbayar mandiri!", slide_bullet)
    ]
    slides_content.append(make_slide("Q07 · Prescriptive: FFB Transport Scheduling", "10 / Prescriptive Analysis", s10_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q07/Q07_transport_scheduling_scenario.png"))

    # SLIDE 11: Q08 FFB Grading Improvement Scenario
    s11_items = [
        Paragraph("<b>Skenario Penurunan 15% Rejection Rate via Early Inspection:</b>", slide_body),
        Paragraph("• <b>Volume Diselamatkan</b>: Menyelamatkan <b>4,35 lot</b> dari penolakan gerbang pabrik.", slide_bullet),
        Paragraph("• <b>Pendapatan Penjualan Tambahan</b>: $4,35 \\times 37.431\\text{ MYR} = \\mathbf{+162.824,89\\text{ MYR}}$ (+713,97 Juta IDR).", slide_bullet),
        Paragraph("• <b>Logika Sunk Cost Buah</b>: Biaya tanam kebun (MYR 23.277/lot) sudah hangus saat panen; memproses buah menjadi CPO <b>tidak mengeluarkan biaya tanam baru</b>.", slide_bullet),
        Paragraph("• <b>Biaya Olah Tambahan (Marginal Milling)</b>: $4,35 \\times 5.672\\text{ MYR} = -24.673,46\\text{ MYR}$.", slide_bullet),
        Paragraph("• <b>Beban Program</b>: CAPEX alat uji NIR portabel (MYR 20.000) + OPEX (MYR 5.000).", slide_bullet),
        Paragraph("• <b>Net Financial Benefit</b>: <b>+113.151,43 MYR (+496,15 Juta IDR) | ROI = 452,6%</b>. <b>PRIORITAS UTAMA #1</b>.", slide_bullet)
    ]
    slides_content.append(make_slide("Q08 · Prescriptive: FFB Grading Improvement", "11 / Prescriptive Analysis", s11_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q08/Q08_ffb_rejection_reduction_model.png"))

    # SLIDE 12: Q09 Milling Capacity Investment Scenario
    s12_items = [
        Paragraph("<b>Skenario Peningkatan Kapasitas Sterilisasi 15%:</b>", slide_body),
        Paragraph("• <b>Dampak Operasional</b>: Siklus perebusan turun dari 81,2 menit menjadi 70,6 menit (menghemat 33,4 jam operasi).", slide_bullet),
        Paragraph("• <b>Kasus Permintaan Tetap (Fixed Demand - 189 Lot)</b>: Penjualan baru = 0,00 MYR. Perusahaan menanggung CAPEX (MYR 110.000) dan OPEX uap (MYR 15.000). <b>Rugi bersih = -125.000,00 MYR (-548,11 Juta IDR)</b>.", slide_bullet),
        Paragraph("• <b>Kasus Permintaan Tumbuh (+15% Panen Baru)</b>: Laba bersih positif +78.450 MYR.", slide_bullet),
        Paragraph("• <b>Prinsip Evaluasi</b>: <i>'Capacity increase bukan otomatis incremental sales'</i>. Menambah mesin pada permintaan tetap hanya menciptakan kapasitas menganggur.", slide_bullet),
        Paragraph("• <b>Keputusan Manajemen</b>: <b>TOLAK investasi fisik sterilizer</b>; gunakan penataan jadwal perebusan internal.", slide_bullet)
    ]
    slides_content.append(make_slide("Q09 · Prescriptive: Milling Capacity Investment", "12 / Prescriptive Analysis", s12_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q09/Q09_milling_capacity_investment_model.png"))

    # SLIDE 13: Q10 Estate-to-Mill Business Case Ranking
    s13_items = [
        Paragraph("<b>Peringkat Prioritas Perbaikan Proses Bisnis:</b>", slide_body),
        Paragraph("• <b>Prioritas 1 (Q08 - Grading Kebun di TPH)</b>: Net Benefit <b>+113.151,43 MYR (+496,15 Juta IDR)</b>. Memulihkan sunk cost buah yang dibuang.", slide_bullet),
        Paragraph("• <b>Prioritas 2 (Q06 - Stabilisasi Mutu CPO)</b>: Net Benefit <b>+9.703,82 MYR (+42,55 Juta IDR)</b>. Mengurangi 50% klaim penalti mutu pembeli dan 40% retest lab.", slide_bullet),
        Paragraph("• <b>Peringkat 3 (Q07 - Transport Scheduling)</b>: Net Benefit -3.910 MYR (Biaya software > penghematan BBM).", slide_bullet),
        Paragraph("• <b>Peringkat 4 (Q09 - Sterilizer CAPEX)</b>: Net Benefit -125.000 MYR (Investasi mesin tidak layak pada demand tetap).", slide_bullet),
        Paragraph("• <b>Portofolio Rekomendasi (P1 + P2)</b>: Memberikan total keuntungan bersih <b>+122.855,25 MYR (+538,70 Juta IDR)</b>.", slide_bullet)
    ]
    slides_content.append(make_slide("Q10 · Prescriptive: Business Case Prioritization", "13 / Prescriptive Analysis", s13_items, "24SI1_Group03_Palm_Oil/03_CELONIS_EVIDENCE/Q10/Q10_business_case_ranking_myr_idr.png"))

    # SLIDE 14: Scenario Comparison (As-Is vs No-Action vs To-Be)
    s14_table = [
        [Paragraph("Indikator Finansial", th_style), Paragraph("Kondisi As-Is", th_style), Paragraph("No-Action Scenario", th_style), Paragraph("Rekomendasi To-Be (P1+P2)", th_style), Paragraph("Pertumbuhan Finansial", th_style)],
        [Paragraph("Pendapatan Bersih (MYR)", td_style), Paragraph("7.074.461,68 MYR", td_style), Paragraph("7.074.461,68 MYR", td_style), Paragraph("<b>7.247.761,11 MYR</b>", td_style), Paragraph("+173.299,43 MYR", td_style)],
        [Paragraph("Pendapatan Bersih (IDR)", td_style), Paragraph("31.020.593.293 IDR", td_style), Paragraph("31.020.593.293 IDR", td_style), Paragraph("<b>31.780.487.043 IDR</b>", td_style), Paragraph("+759.893.749 IDR", td_style)],
        [Paragraph("Total Biaya Operasional (MYR)", td_style), Paragraph("6.216.045,66 MYR", td_style), Paragraph("6.216.045,66 MYR", td_style), Paragraph("6.266.489,84 MYR", td_style), Paragraph("+50.444,18 MYR", td_style)],
        [Paragraph("Total Biaya Operasional (IDR)", td_style), Paragraph("27.256.552.699 IDR", td_style), Paragraph("27.256.552.699 IDR", td_style), Paragraph("27.477.743.266 IDR", td_style), Paragraph("+221.190.567 IDR", td_style)],
        [Paragraph("<b>Profit Contribution (MYR)</b>", td_style), Paragraph("<b>858.416,02 MYR</b>", td_style), Paragraph("<b>858.416,02 MYR</b>", td_style), Paragraph("<b>981.271,27 MYR</b>", td_style), Paragraph("<b>+122.855,25 MYR (+14,31%)</b>", td_style)],
        [Paragraph("<b>Profit Contribution (IDR)</b>", td_style), Paragraph("<b>3.764.040.595 IDR</b>", td_style), Paragraph("<b>3.764.040.595 IDR</b>", td_style), Paragraph("<b>4.302.744.889 IDR</b>", td_style), Paragraph("<b>+538.704.294 IDR (+14,31%)</b>", td_style)],
        [Paragraph("Total Investasi Program (MYR)", td_style), Paragraph("0,00 MYR", td_style), Paragraph("0,00 MYR", td_style), Paragraph("28.000,00 MYR", td_style), Paragraph("Payback < 6 Bulan", td_style)]
    ]
    t_s14 = Table(s14_table, colWidths=[120, 95, 95, 110, 90])
    t_s14.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#1b4332')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dee2e6')),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor('#f8f9fa')])
    ]))
    s14_items = [
        Paragraph("<b>Perbandingan Kuantitatif Skenario Bisnis Menyeluruh:</b>", slide_body),
        Spacer(1, 4),
        t_s14,
        Spacer(1, 6),
        Paragraph("• Laba kontribusi melonjak <b>+14,31% (+538,70 Juta IDR)</b> dengan payback period investasi < 6 bulan.", slide_body)
    ]
    slides_content.append(make_slide("Financial Scenario Comparison: As-Is vs. No-Action vs. To-Be", "14 / Financial Decision", s14_items))

    # SLIDE 15: Management Recommendations & Action Plan
    s15_items = [
        Paragraph("<b>Keputusan Final & Rencana Implementasi Manajemen:</b>", slide_body),
        Paragraph("1. <b>Eksekusi Segera Prioritas 1 (Q08 - Grading Kebun di TPH)</b>: Alokasikan CAPEX MYR 20.000 pada Q1 2027 untuk pengadaan 4 unit scanner NIR portabel dan SOP penolakan buah di TPH sebelum dimuat ke truk.", slide_bullet),
        Paragraph("2. <b>Eksekusi Prioritas 2 (Q06 - Otomasi Kontrol Suhu Pemurnian Minyak)</b>: Alokasikan MYR 8.000 untuk sensor suhu di purifier dan vacuum dryer guna mencegah denda klaim mutu dari pembeli.", slide_bullet),
        Paragraph("3. <b>Tolak Belanja Modal Mesin Baru (Q09) & Software Truk (Q07)</b>: Jangan beli mesin sterilisasi baru (hemat MYR 110.000) dan software dispatch truk (hemat MYR 6.000) karena tidak memberikan pengembalian kas positif.", slide_bullet),
        Paragraph("4. <b>Rencana Pengendalian Risiko</b>: Luncurkan skema insentif kualitas panen bagi mandor dan terapkan batas waktu maksimal pengangkutan dari panen ke pabrik $\le 3,0$ jam.", slide_bullet),
        Paragraph("• <b>Total Dampak Keberhasilan</b>: Meningkatkan laba kontribusi perusahaan menjadi <b>4,30 Miliar IDR</b> (+14,31%).", slide_body)
    ]
    slides_content.append(make_slide("Management Recommendations & Strategic Action Plan", "15 / Strategic Decision", s15_items))

    # SLIDE 16: Appendix & Audit Trail References
    s16_items = [
        Paragraph("<b>Referensi & Jejak Audit (Appendix & Data Provenance):</b>", slide_body),
        Paragraph("• <b>Cleaned Event Log CSV</b>: `01_DATA/cleaned/celonis_event_log_clean.csv` (6.179 event / 230 lot).", slide_bullet),
        Paragraph("• <b>Laporan Kualitas Data</b>: `01_DATA/validation/data_quality_report.md` (Dokumentasi karantina RAW-0005170).", slide_bullet),
        Paragraph("• <b>Naskah SQL DuckDB</b>: `02_SQL/` (00_import.sql s/d 05_celonis_export.sql) dan `queries_by_question/Q01.sql s/d Q10.sql`.", slide_bullet),
        Paragraph("• <b>Bukti Visual Celonis</b>: `03_CELONIS_EVIDENCE/` (13 grafik analisis proses & finansial resolusi tinggi).", slide_bullet),
        Paragraph("• <b>Jawaban Lengkap Q01–Q10</b>: `04_JAWABAN/Q01/jawaban.md` hingga `04_JAWABAN/Q10/jawaban.md`.", slide_bullet),
        Paragraph("• <b>Dokumentasi Kurs BI & Finansial</b>: `05_FINANCIAL/exchange_rate.csv` (1 MYR = 4.384,87 IDR per 13 Okt 2026).", slide_bullet),
        Paragraph("• <b>Executive Summary</b>: `07_EXECUTIVE_SUMMARY/executive_summary.pdf` | Kontribusi Anggota: `08_CONTRIBUTIONS/`.", slide_bullet)
    ]
    slides_content.append(make_slide("Appendix: Audit Trail, SQL & Document Directory", "16 / Appendix", s16_items))

    # Assemble all slides with PageBreak
    story = []
    for i, slide in enumerate(slides_content):
        story.extend(slide)
        if i < len(slides_content) - 1:
            story.append(PageBreak())

    doc.build(story)
    print("Presentation Slides PDF created successfully.")

if __name__ == '__main__':
    build_executive_summary()
    build_presentation_slides()
