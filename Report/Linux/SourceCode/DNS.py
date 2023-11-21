from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
import re

def read_dns_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_dns_info(lines):
    dns_entries = []
    current_boot = ""

    for line in lines:
        if "DNS Cache" in line:
            continue
        elif "-- Boot" in line:
            current_boot = line.strip()
        else:
            # Split the line into date_time, hostname, content
            match = re.match(r'(\d+월 \d+ \d+:\d+:\d+) (\S+)(.*)', line.strip())
            if match:
                date_time, hostname, content = match.group(1), match.group(2), match.group(3)
                date, time = date_time.split(maxsplit=1)  # Split date_time into date and time
                dns_entries.append({
                    "Date": date,
                    "Time": time,
                    "Hostname": hostname,
                    "Content": content,
                    "Boot": current_boot
                })

    return dns_entries

def create_dns_info_pdf(filename, dns_entries):
    doc = SimpleDocTemplate(filename, pagesize=A4)
    elements = []

    # Title paragraph
    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>DNS Info</b>", title_style)
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [["Date/Time", "Hostname", "Content", "Boot"]]
    for entry in dns_entries:
        data.append([
            Paragraph(entry["Date"] + " " + entry["Time"], styles['Normal']),
            Paragraph(entry["Hostname"], styles['Normal']),
            Paragraph(entry["Content"], styles['Normal']),
            Paragraph(entry["Boot"], styles['Normal'])
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

    table = Table(data, colWidths=[120, 80, 200, 150])
    table.setStyle(TableStyle(table_style))

    elements.append(table)
    doc.build(elements)

def DNS():
    dns_info = read_dns_info('Network/DNS.txt')
    dns_entries = parse_dns_info(dns_info)
    create_dns_info_pdf('dns_info.pdf', dns_entries)
    print("dns_info.pdf 생성 완료")