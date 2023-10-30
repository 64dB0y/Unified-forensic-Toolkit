from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from io import BytesIO

def read_shortcut_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_shortcut_info(lines):
    shortcut_info = []

    for line in lines:
        if line.strip():
            shortcut_info.append(line.strip())

    return shortcut_info

def create_shortcut_pdf(filename, shortcut_info):
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elements = []

    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>Shortcut Info</b>", title_style)
    elements.append(title)
    elements.append(Paragraph("<br/>", title_style))

    data = []
    for info in shortcut_info:
        attribute, value = info.split(':', 1)
        data.append([attribute, value.strip()])

    table_style = [
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),  # 각 셀에 대한 테두리 설정
        ('BACKGROUND', (0, 0), (0, -1), colors.beige),  # 첫 번째 열의 배경색 설정
    ]

    table = Table(data, colWidths=[100, 300])
    table.setStyle(TableStyle(table_style))
    elements.append(table)

    doc.build(elements)

if __name__ == "__main__":
    shortcut_info = read_shortcut_info('shortcut.metadata.txt')
    parsed_shortcut_info = parse_shortcut_info(shortcut_info)
    create_shortcut_pdf('shortcut.pdf', parsed_shortcut_info)
