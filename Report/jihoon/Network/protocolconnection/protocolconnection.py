from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib import colors
from reportlab.platypus import Paragraph
from io import BytesIO
import re

def read_protocol_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_protocol_info(lines):
    protocols = []

    # Flag to start parsing the protocol table
    start_parsing = False

    for line in lines:
        # Check for the line that indicates the start of the protocol table
        if "Proto" in line and "Local Address" in line:
            start_parsing = True
            continue

        if start_parsing:
            parts = line.split()
            if len(parts) >= 5:
                proto, recv_q, send_q, local_address, foreign_address = parts[:5]
                state = ' '.join(parts[5:])
                protocols.append({
                    "Proto": proto,
                    "Recv-Q": recv_q,
                    "Send-Q": send_q,
                    "Local Address": local_address,
                    "Foreign Address": foreign_address,
                    "State": state
                })

    return protocols


def create_protocol_info_pdf(filename, protocols):
    doc = SimpleDocTemplate(filename, pagesize=letter, leftMargin=30)
    elements = []

    # Title paragraph
    title = Paragraph("<b>Protocol Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [["Proto", "Recv-Q", "Send-Q", "Local Address", "Foreign Address", "State"]]
    for protocol in protocols:
        data.append([
            protocol["Proto"],
            protocol["Recv-Q"],
            protocol["Send-Q"],
            protocol["Local Address"],
            protocol["Foreign Address"],
            protocol["State"]
        ])

    table = Table(data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),  # 표를 왼쪽으로 정렬
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)
    doc.build(elements)

if __name__ == "__main__":
    protocol_info = read_protocol_info('protocolconnection.txt')
    protocols = parse_protocol_info(protocol_info)
    create_protocol_info_pdf('protocolconnection_info.pdf', protocols)
