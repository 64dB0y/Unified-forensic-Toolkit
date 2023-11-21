from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib import colors  # colors 모듈을 import 추가
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet

def read_autoinfo(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_autoinfo(lines):
    autoinfo_entries = []

    for line in lines:
        # Split the line into columns
        columns = line.strip().split()

        if len(columns) >= 9:
            permissions, _, _, _, size, month, day, year, name = columns
            # Join the date components back together
            date = f"{month} {day} {year}"
            autoinfo_entries.append({
                "Permissions": permissions,
                "Size": size,
                "Date": date,
                "Name": name
            })

    return autoinfo_entries

def create_autoinfo_pdf(filename, autoinfo_info):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter))  # 가로 방향 페이지 사용
    elements = []

    # Title paragraph
    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>Autoinfo</b>", title_style)
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [["Permissions", "Size", "Date", "Name"]]
    for entry in autoinfo_info:
        data.append([
            Paragraph(entry["Permissions"], styles['Normal']),
            Paragraph(entry["Size"], styles['Normal']),
            Paragraph(entry["Date"], styles['Normal']),
            Paragraph(entry["Name"], styles['Normal'])
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
    doc.build(elements)

def autoinfo():
    autoinfo_info = read_autoinfo('Autorun/autoinfo.txt')
    autoinfo_entries = parse_autoinfo(autoinfo_info)
    create_autoinfo_pdf('autoinfo.pdf', autoinfo_entries)
    print("autoinfo.pdf 생성 완료")
