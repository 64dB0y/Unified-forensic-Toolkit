from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib import colors
from reportlab.platypus import Paragraph
import re

def read_isof_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_isof_info(lines):
    isof_entries = []

    for line in lines:
        parts = re.split(r'\s+', line.strip())
        if len(parts) >= 9:
            command, pid, user, fd, fd_type, device, size_off, node, name = parts[:9]
            isof_entries.append({
                "COMMAND": command,
                "PID": pid,
                "USER": user,
                "FD": fd,
                "TYPE": fd_type,
                "DEVICE": device,
                "SIZE/OFF": size_off,
                "NODE": node,
                "NAME": name
            })

    return isof_entries

def create_isof_info_pdf(filename, isof_entries):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter), leftMargin=30)
    elements = []

    # Title paragraph
    title = Paragraph("<b>lsof -i -n Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [
        ["COMMAND", "PID", "USER", "FD", "TYPE", "DEVICE", "SIZE/OFF", "NODE", "NAME"]
    ]
    for entry in isof_entries:
        data.append([
            entry["COMMAND"],
            entry["PID"],
            entry["USER"],
            entry["FD"],
            entry["TYPE"],
            entry["DEVICE"],
            entry["SIZE/OFF"],
            entry["NODE"],
            entry["NAME"]
        ])

    table = Table(data, colWidths=None)  # colWidths를 None으로 설정
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)
    doc.build(elements)

def ISOF():
    isof_info = read_isof_info('Network/lsof.txt')
    isof_entries = parse_isof_info(isof_info)
    create_isof_info_pdf('lsof_info.pdf', isof_entries)
    print("isof_info.pdf 생성 완료")
