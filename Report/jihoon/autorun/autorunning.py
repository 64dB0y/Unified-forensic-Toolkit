from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from io import BytesIO

def read_autorunning(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        last_line = lines[-1].strip()  # 마지막 줄을 추출
    return lines, last_line

def create_autorunning_pdf(filename, autorunning_info):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter))
    elements = []

    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>Autorunning</b>", title_style)
    elements.append(title)
    elements.append(Spacer(1, 12))

    lines, last_line = autorunning_info
    data = [["Unit File", "State", "Vendor Preset"]]
    for entry in lines[1:-1]:  # 첫 번째 줄을 제외하고 마지막 줄을 제외한 나머지 줄을 처리
        columns = entry.strip().split()
        if len(columns) >= 3:
            unit_file, state, vendor_preset = columns[:3]
            data.append([
                Paragraph(unit_file, styles['Normal']),
                Paragraph(state, styles['Normal']),
                Paragraph(vendor_preset, styles['Normal'])
            ])

    table_style = [
        ('BACKGROUND', (0, 0), (-1, 0), (0.7, 0.7, 0.7)),
        ('TEXTCOLOR', (0, 0), (-1, 0), (1, 1, 1)),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black)
    ]

    table = Table(data, colWidths='*')
    table.setStyle(TableStyle(table_style))
    elements.append(table)

    # 마지막 줄을 텍스트로 출력
    elements.append(Spacer(1, 12))
    elements.append(Paragraph(last_line, styles['Normal']))

    doc.build(elements)

if __name__ == "__main__":
    autorunning_info = read_autorunning('autorunning.txt')
    create_autorunning_pdf('autorunning.pdf', autorunning_info)