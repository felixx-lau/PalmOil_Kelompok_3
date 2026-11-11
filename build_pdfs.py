"""Build Word deliverables and two PDFs from the current Markdown sources.

Use the Codex bundled Python (python-docx and reportlab). Markdown files are the
content authority; no financial or analytical numbers are hardcoded here.
"""
from pathlib import Path
import re, os
from html import escape
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

ROOT=Path(__file__).resolve().parent
CURRENT_DOC=None
FONT=Path('/System/Library/Fonts/Supplemental')
pdfmetrics.registerFont(TTFont('ArialPalm',str(FONT/'Arial.ttf')))
pdfmetrics.registerFont(TTFont('ArialPalmBold',str(FONT/'Arial Bold.ttf')))
pdfmetrics.registerFontFamily('ArialPalm',normal='ArialPalm',bold='ArialPalmBold',italic='ArialPalm',boldItalic='ArialPalmBold')

def clean(text):
    text=re.sub(r'\$([^$]+)\$',r'\1',text)
    text=re.sub(r'\\(?:text|mathrm)\{([^}]+)\}',r'\1',text)
    text=text.replace('\\rightarrow','→').replace('\\times','×').replace('\\Delta','Δ')
    return text

def blocks(text):
    lines=text.splitlines();i=0
    while i<len(lines):
        line=lines[i].strip()
        if not line or line=='---':i+=1;continue
        if line=='<!-- pagebreak -->':yield 'break','';i+=1;continue
        if line.startswith('```'):
            i+=1;ls=[]
            while i<len(lines) and not lines[i].startswith('```'):ls.append(lines[i]);i+=1
            yield 'code','\n'.join(ls);i+=1;continue
        if line.startswith('|'):
            table=[]
            while i<len(lines) and lines[i].strip().startswith('|'):
                cells=[x.strip() for x in lines[i].strip().strip('|').split('|')]
                if not all(re.fullmatch('[: -]+',x or '-') for x in cells):table.append(cells)
                i+=1
            yield 'table',table;continue
        if line.startswith('#'):
            m=re.match(r'(#+)\s*(.*)',line);yield 'heading'+str(len(m[1])),m[2];i+=1;continue
        if line.startswith('- '):yield 'bullet',line[2:];i+=1;continue
        m=re.match(r'^\d+\.\s+(.*)',line)
        if m:yield 'number',line;i+=1;continue
        yield 'paragraph',line.lstrip('> ');i+=1

def add_inline(paragraph,text,source):
    # Preserve actual hyperlinks, including relative repository references.
    parts=re.split(r'(\[[^\]]+\]\([^)]+\)|\*\*[^*]+\*\*|`[^`]+`)',clean(text))
    for part in parts:
        m=re.fullmatch(r'\[([^\]]+)\]\(([^)]+)\)',part)
        if m:
            label,target=m.groups();target=target.strip('<>')
            if not re.match(r'^[a-zA-Z]+:',target) and CURRENT_DOC is not None:
                target=os.path.relpath((source.parent/target).resolve(),CURRENT_DOC.parent)
            link=OxmlElement('w:hyperlink')
            from docx.opc.constants import RELATIONSHIP_TYPE as RT
            link.set(qn('r:id'),paragraph.part.relate_to(target,RT.HYPERLINK,is_external=True))
            run=OxmlElement('w:r');props=OxmlElement('w:rPr');col=OxmlElement('w:color');col.set(qn('w:val'),'1F5F7A');props.append(col);run.append(props)
            t=OxmlElement('w:t');t.text=label;run.append(t);link.append(run);paragraph._p.append(link)
        else:
            run=paragraph.add_run(part.strip('`').replace('**',''))
            if part.startswith('**'):run.bold=True
            if part.startswith('`'):run.font.name='Courier New';run.font.size=Pt(9)

def document_setup(doc,slides=False,portrait=False):
    sec=doc.sections[0]
    if portrait:sec.page_width=Inches(8.27);sec.page_height=Inches(11.69)
    else:sec.page_width=Inches(11.69);sec.page_height=Inches(8.27)
    sec.top_margin=sec.bottom_margin=Inches(.60)
    sec.left_margin=sec.right_margin=Inches(.65)
    for st in doc.styles:
        if st.element.pPr is not None:
            for border in list(st.element.pPr.findall(qn('w:pBdr'))):st.element.pPr.remove(border)
    for name in ['Normal','Title','Heading 1','Heading 2','Heading 3','Heading 4']:
        st=doc.styles[name];st.font.name='Arial';st.font.color.rgb=RGBColor(0,0,0)
        st.font.size=Pt(10.5 if name=='Normal' else {'Title':22,'Heading 1':17,'Heading 2':14,'Heading 3':12,'Heading 4':11}[name])
        st.paragraph_format.space_after=Pt(6)
    doc.styles['Normal'].paragraph_format.line_spacing=1.12
    footer=sec.footer.paragraphs[0];footer.alignment=WD_ALIGN_PARAGRAPH.RIGHT
    r=footer.add_run('24SI1 Group 03 | Rilis 11 November 2026 | ');r.font.size=Pt(8)
    field=OxmlElement('w:fldSimple');field.set(qn('w:instr'),'PAGE');footer._p.append(field)

def add_md(doc,source,is_first=False):
    first=True
    for kind,data in blocks(source.read_text()):
        if kind=='break':doc.add_page_break();continue
        if kind.startswith('heading'):
            level=int(kind[7:]);text=re.sub(r'[^\w\s]',' ',data);text=re.sub(r'\s+',' ',text).strip()
            p=doc.add_paragraph(style='Title' if first and is_first else f'Heading {min(level,4)}');p.add_run(text);first=False
        elif kind=='table':
            n=max(map(len,data));t=doc.add_table(rows=0,cols=n);t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
            widths=[]
            for i in range(n):widths.append(max(10,min(45,max(len(re.sub(r'[*`$]','',r[i])) if i<len(r) else 0 for r in data))))
            total=sum(widths);usable=doc.sections[-1].page_width-doc.sections[-1].left_margin-doc.sections[-1].right_margin
            for j,w in enumerate(widths):t.columns[j].width=int(usable*w/total)
            for i,row in enumerate(data):
                cells=t.add_row().cells
                for j,c in enumerate(cells):
                    c.width=int(usable*widths[j]/total);c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
                    tcpr=c._tc.get_or_add_tcPr();b=OxmlElement('w:tcBorders')
                    for side in ('top','left','bottom','right'):
                        x=OxmlElement('w:'+side);x.set(qn('w:val'),'single');x.set(qn('w:sz'),'4');x.set(qn('w:color'),'D9D9D9');b.append(x)
                    tcpr.append(b);m=OxmlElement('w:tcMar')
                    for side in ('top','left','bottom','right'):
                        x=OxmlElement('w:'+side);x.set(qn('w:w'),'75');x.set(qn('w:type'),'dxa');m.append(x)
                    tcpr.append(m)
                    if i==0 or i%2==0:
                        shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'DCEAF0' if i==0 else 'F5F7F8');tcpr.append(shade)
                    p=c.paragraphs[0];p.paragraph_format.space_after=Pt(3);p.paragraph_format.space_before=Pt(3)
                    value=row[j] if j<len(row) else ''
                    add_inline(p,value,source)
                    for run in p.runs:run.font.size=Pt(9 if n<=6 else 8);run.bold=run.bold or i==0
                    if j>0:p.alignment=WD_ALIGN_PARAGRAPH.CENTER
                if i==0:
                    repeat=OxmlElement('w:tblHeader');t.rows[i]._tr.get_or_add_trPr().append(repeat)
                # A row may move to the next page, but never split its text.
                prevent=OxmlElement('w:cantSplit');t.rows[i]._tr.get_or_add_trPr().append(prevent)
            doc.add_paragraph().paragraph_format.space_after=Pt(2)
        else:
            p=doc.add_paragraph(style='List Bullet' if kind=='bullet' else 'Normal')
            add_inline(p,data,source)
            if kind=='code':
                for run in p.runs:run.font.name='Courier New';run.font.size=Pt(9)
    return doc

def build_word():
    global CURRENT_DOC
    sources=[ROOT/f'04_JAWABAN/Q{i:02}/jawaban.md' for i in range(1,11)]+[ROOT/p for p in ['00_START_HERE/README.md','01_DATA/validation/data_quality_report.md','05_FINANCIAL/scenario_assumptions.md','06_PRESENTATION/slides.md','07_EXECUTIVE_SUMMARY/executive_summary.md']]
    for source in sources:
        CURRENT_DOC=source.with_suffix('.docx')
        doc=Document();document_setup(doc,slides=source.stem=='slides',portrait=source.stem=='executive_summary')
        if source.stem=='executive_summary':
            doc.styles['Normal'].font.size=Pt(9.5)
            doc.styles['Normal'].paragraph_format.space_after=Pt(4)
            doc.styles['Normal'].paragraph_format.line_spacing=1.05
        add_md(doc,source,True);doc.save(source.with_suffix('.docx'))
    CURRENT_DOC=ROOT/'00_START_HERE/PALM_OIL_PROCESS_MINING_FULL_REPORT.docx'
    doc=Document();document_setup(doc)
    doc.add_paragraph('Laporan analisis proses Palm Oil',style='Title')
    doc.add_paragraph('24SI1 Group 03 | Rilis final cleaning 11 November 2026')
    doc.add_paragraph('Analisis Q01 sampai Q10 pada data sintetis. Seluruh angka berasal dari rilis CSV yang sama; satu event dikarantina. Grafik SQL dan tangkapan layar antarmuka lama dibedakan menurut manifest bukti.')
    for source in [ROOT/'01_DATA/validation/data_quality_report.md']+sources[:10]+[ROOT/'05_FINANCIAL/scenario_assumptions.md']:
        doc.add_page_break();add_md(doc,source)
    doc.save(ROOT/'00_START_HERE/PALM_OIL_PROCESS_MINING_FULL_REPORT.docx')
    print('Updated 16 Word documents from Markdown.')

def htmltext(text):
    text=re.sub(r'\[([^\]]+)\]\([^)]+\)',r'\1',clean(text))
    text=escape(text).replace('`','')
    return re.sub(r'\*\*([^*]+)\*\*',r'<b>\1</b>',text)

def executive_pdf():
    style=ParagraphStyle('body',fontName='ArialPalm',fontSize=9.3,leading=12.7,spaceAfter=7)
    h=ParagraphStyle('head',parent=style,fontName='ArialPalmBold',fontSize=12,leading=15,spaceBefore=10,spaceAfter=7)
    title=ParagraphStyle('title',parent=h,fontSize=21,leading=25,spaceAfter=12)
    cell=ParagraphStyle('cell',parent=style,fontSize=8.3,leading=11,spaceAfter=0)
    flow=[]
    for kind,data in blocks((ROOT/'07_EXECUTIVE_SUMMARY/executive_summary.md').read_text()):
        if kind=='break':flow.append(PageBreak())
        elif kind=='table':
            values=[[Paragraph(htmltext(x),cell) for x in row] for row in data]
            width=523;ws=[width*.22,width*.78] if len(data[0])==2 else [width*.24,width*.18,width*.58]
            t=Table(values,colWidths=ws,hAlign='LEFT',repeatRows=1)
            t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#DCEAF0')),('GRID',(0,0),(-1,-1),.4,colors.HexColor('#D9D9D9')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)]));flow.extend([t,Spacer(1,8)])
        else:flow.append(Paragraph(htmltext(data),title if kind=='heading1' else h if kind.startswith('heading') else style))
    def footer(c,d):
        c.setFont('ArialPalm',8);c.setFillColor(colors.HexColor('#555555'));c.drawString(36,20,'24SI1 Group 03 | Rilis 11 November 2026');c.drawRightString(559,20,str(d.page))
    SimpleDocTemplate(str(ROOT/'07_EXECUTIVE_SUMMARY/executive_summary.pdf'),pagesize=(595,842),leftMargin=36,rightMargin=36,topMargin=34,bottomMargin=35).build(flow,onFirstPage=footer,onLaterPages=footer)

def slides_pdf():
    chunks=(ROOT/'06_PRESENTATION/slides.md').read_text().split('<!-- pagebreak -->')
    c=canvas.Canvas(str(ROOT/'06_PRESENTATION/slides.pdf'),pagesize=(960,540))
    c.setTitle('Analisis Palm Oil setelah final cleaning');c.setAuthor('24SI1 Group 03')
    charts={4:'Q01/Q01_variants_sql.png',6:'Q02/Q02_outcomes_sql.png',7:'Q03/Q03_stage_waiting_sql.png',8:'Q04/Q04_buckets_sql.png',9:'Q05/Q05_daily_load_sql.png',14:'Q10/Q10_scenario_sql.png'}
    for i,chunk in enumerate(chunks,1):
        bs=list(blocks(chunk));heading=bs[0][1];bullets=[x[1] for x in bs[1:]]
        c.setFillColor(colors.HexColor('#1B4332'));c.rect(0,0,960,540,fill=1,stroke=0)
        c.setFillColor(colors.white)
        t=Paragraph(htmltext(heading),ParagraphStyle('t',fontName='ArialPalmBold',fontSize=29,leading=35,textColor=colors.white))
        _,height=t.wrap(860,100);t.drawOn(c,48,488-height)
        c.setStrokeColor(colors.HexColor('#73A58A'));c.line(48,465-height,912,465-height)
        has_chart=i in charts;width=440 if has_chart else 850;y=438-height
        for bullet in bullets:
            text=Paragraph('• '+htmltext(bullet),ParagraphStyle('b',fontName='ArialPalm',fontSize=17 if has_chart else 21,leading=24 if has_chart else 29,textColor=colors.white))
            _,bh=text.wrap(width,400);text.drawOn(c,52,y-bh);y-=bh+18
        if has_chart:
            image=ROOT/'03_CELONIS_EVIDENCE'/charts[i]
            c.setFillColor(colors.white);c.roundRect(518,130,394,255,5,fill=1,stroke=0)
            c.drawImage(ImageReader(str(image)),523,135,width=384,height=245,preserveAspectRatio=True,anchor='c',mask='auto')
        c.setFillColor(colors.HexColor('#DDE9E1'));c.setFont('ArialPalm',9)
        c.drawString(48,29,'24SI1 Group 03 | Rilis 11 November 2026 | Sumber: CSV bersih, hasil DuckDB Q01–Q10, model skenario')
        c.drawRightString(912,29,f'{i:02} / {len(chunks):02}');c.showPage()
    c.save()

if __name__=='__main__':
    build_word();executive_pdf();slides_pdf();print('Updated executive summary PDF and 16-slide PDF.')
