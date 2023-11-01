from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, PageTemplate, Frame
from reportlab.lib import colors
from reportlab.platypus import Paragraph
from io import BytesIO
import re

def read_txt_data(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()[2:]  # 첫 번째 줄을 제외한 나머지 줄만 읽음
    return lines

def parse_txt_data(lines):
    txt_entries = []

    for line in lines:
        parts = re.split(r'\s+', line.strip())
        if len(parts) >= 11:
            user, pid, cpu, mem, vsz, rss, tty, stat, start, time, command = parts[:11]
            txt_entries.append({
                "USER": user,
                "PID": pid,
                "CPU": cpu,
                "MEM": mem,
                "VSZ": vsz,
                "RSS": rss,
                "TTY": tty,
                "STAT": stat,
                "START": start,
                "TIME": time,
                "COMMAND": command
            })

    return txt_entries

def create_txt_data_pdf(filename, txt_entries):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter), leftMargin=30)
    elements = []

    # Title paragraph
    title = Paragraph("<b>PS AUX Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [
        ["USER", "PID", "CPU", "MEM", "VSZ", "RSS", "TTY", "STAT", "START", "TIME", "COMMAND"]
    ]
    for entry in txt_entries:
        data.append([
            entry["USER"],
            entry["PID"],
            entry["CPU"],
            entry["MEM"],
            entry["VSZ"],
            entry["RSS"],
            entry["TTY"],
            entry["STAT"],
            entry["START"],
            entry["TIME"],
            entry["COMMAND"]
        ])

    table = Table(data, colWidths=None)
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

if __name__ == "__main__":
    txt_data = read_txt_data('psaux.txt')
    txt_entries = parse_txt_data(txt_data)
    create_txt_data_pdf('psaux_info.pdf', txt_entries)
